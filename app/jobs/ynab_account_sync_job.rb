class YnabAccountSyncJob < ApplicationJob
  queue_as :default

  def perform(plan_id)
    ynab = Ynab::ClientService.new.client

    knowledge_record = ServerKnowledge.find_or_initialize_by(plan_id: plan_id, topic: "accounts")
    last_knowledge = knowledge_record.knowledge

    response = if last_knowledge
                 ynab.accounts.get_accounts(plan_id, last_knowledge_of_server: last_knowledge)
    else
                 ynab.accounts.get_accounts(plan_id)
    end

    data = response.data

    ActiveRecord::Base.transaction do
      data.accounts.each do |item|
        if item.deleted
          Account.find_by(ynab_id: item.id)&.destroy
        else
          record = Account.find_or_initialize_by(ynab_id: item.id)

          record.assign_attributes(
            plan_id: plan_id,
            name: item.name,
            account_type: item.type,
            on_budget: item.on_budget,
            closed: item.closed,
            balance: item.balance,
            cleared_balance: item.cleared_balance,
            uncleared_balance: item.uncleared_balance,
            transfer_payee_id: item.transfer_payee_id,
            deleted: item.deleted
          )
          record.save!


        end
      end

      knowledge_record.update!(knowledge: data.server_knowledge)
    end

  rescue StandardError => e
    Rails.logger.error("YnabAccountSyncJob failed for plan_id #{plan_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise e
  end
end
