class YnabScheduledTransactionSyncJob < ApplicationJob
  queue_as :default

  def perform(plan_id)
    ynab = Ynab::ClientService.new.client

    knowledge_record = ServerKnowledge.find_or_initialize_by(plan_id: plan_id, topic: "scheduled_transactions")
    last_knowledge = knowledge_record.knowledge

    response = if last_knowledge
                 ynab.scheduled_transactions.get_scheduled_transactions(plan_id, last_knowledge_of_server: last_knowledge)
    else
                 ynab.scheduled_transactions.get_scheduled_transactions(plan_id)
    end

    data = response.data

    ActiveRecord::Base.transaction do
      data.scheduled_transactions.each do |item|
        if item.deleted
          ScheduledTransaction.find_by(ynab_id: item.id)&.destroy
        else
          record = ScheduledTransaction.find_or_initialize_by(ynab_id: item.id)

          record.assign_attributes(
            plan_id: plan_id,
            date: item.respond_to?(:date_first) ? item.date_first : item.date_next,
            frequency: item.frequency,
            amount: item.amount,
            memo: item.memo,
            flag_color: item.flag_color,
            account_id: item.account_id,
            payee_id: item.payee_id,
            category_id: item.category_id,
            transfer_account_id: item.transfer_account_id,
            deleted: item.deleted
          )
          record.save!


        end
      end

      knowledge_record.update!(knowledge: data.server_knowledge)
    end

  rescue StandardError => e
    Rails.logger.error("YnabScheduledTransactionSyncJob failed for plan_id #{plan_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise e
  end
end
