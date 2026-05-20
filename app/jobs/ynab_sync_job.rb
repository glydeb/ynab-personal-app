class YnabSyncJob < ApplicationJob
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

    # 3. Process the Delta Array
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
end
