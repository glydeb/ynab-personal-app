class YnabTransactionSyncJob < ApplicationJob
  queue_as :default

  def perform(plan_id)
    ynab = Ynab::ClientService.new.client

    # 1. Fetch Server Knowledge High-Water Mark
    knowledge_record = ServerKnowledge.find_or_initialize_by(plan_id: plan_id, topic: "transactions")
    last_knowledge = knowledge_record.knowledge

    # 2. Make Delta Request via SDK
    response = if last_knowledge
                 ynab.transactions.get_transactions(plan_id, last_knowledge_of_server: last_knowledge)
    else
                 ynab.transactions.get_transactions(plan_id)
    end

    data = response.data

    referenced_payee_ids = []
    referenced_category_ids = []

    data.transactions.each do |t|
      referenced_payee_ids << t.payee_id if t.payee_id
      referenced_category_ids << t.category_id if t.category_id

      if t.subtransactions.present?
        t.subtransactions.each do |sub|
          referenced_payee_ids << sub.payee_id if sub.payee_id
          referenced_category_ids << sub.category_id if sub.category_id
        end
      end
    end

    referenced_payee_ids.uniq!
    referenced_category_ids.uniq!

    if referenced_payee_ids.any?
      existing_payees = Payee.where(plan_id: plan_id, ynab_id: referenced_payee_ids).pluck(:ynab_id)
      if (referenced_payee_ids - existing_payees).any?
        YnabPayeeSyncJob.perform_now(plan_id)
      end
    end

    if referenced_category_ids.any?
      existing_categories = Category.where(plan_id: plan_id, ynab_id: referenced_category_ids).pluck(:ynab_id)
      if (referenced_category_ids - existing_categories).any?
        YnabCategorySyncJob.perform_now(plan_id)
      end
    end

    # 3. Process the Delta Array and update Server Knowledge Atomically
    ActiveRecord::Base.transaction do
      data.transactions.each do |t|
        if t.deleted
          YnabTransaction.find_by(ynab_id: t.id)&.destroy
        else
          tx = YnabTransaction.find_or_initialize_by(ynab_id: t.id)

          tx.assign_attributes(
            plan_id: plan_id,
            account_id: t.account_id,
            date: t.date,
            amount: t.amount,
            memo: t.memo,
            cleared: t.cleared,
            approved: t.approved,
            flag_color: t.flag_color,
            payee_id: t.payee_id,
            category_id: t.category_id,
            transfer_account_id: t.transfer_account_id,
            transfer_transaction_id: t.transfer_transaction_id,
            matched_transaction_id: t.matched_transaction_id,
            import_id: t.import_id
          )
          tx.save!

          # Process any subtransactions (splits) included in this transaction
          if t.subtransactions.present?
            t.subtransactions.each do |sub|
              if sub.deleted
                Subtransaction.find_by(ynab_id: sub.id)&.destroy
              else
                stx = Subtransaction.find_or_initialize_by(ynab_id: sub.id)
                stx.assign_attributes(
                  transaction_id: t.id,
                  amount: sub.amount,
                  memo: sub.memo,
                  payee_id: sub.payee_id,
                  category_id: sub.category_id,
                  transfer_account_id: sub.transfer_account_id,
                  transfer_transaction_id: sub.transfer_transaction_id
                )
                stx.save!
              end
            end
          end
        end
      end

      # 4. Save the new Server Knowledge for the next job execution
      knowledge_record.update!(knowledge: data.server_knowledge)
    end
  rescue StandardError => e
    Rails.logger.error("YnabTransactionSyncJob failed for plan_id #{plan_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise e
  end
end
