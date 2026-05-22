class YnabPayeeSyncJob < ApplicationJob
  queue_as :default

  def perform(plan_id)
    ynab = Ynab::ClientService.new.client

    knowledge_record = ServerKnowledge.find_or_initialize_by(plan_id: plan_id, topic: "payees")
    last_knowledge = knowledge_record.knowledge

    response = if last_knowledge
                 ynab.payees.get_payees(plan_id, last_knowledge_of_server: last_knowledge)
    else
                 ynab.payees.get_payees(plan_id)
    end

    data = response.data

    ActiveRecord::Base.transaction do
      data.payees.each do |item|
        if item.deleted
          Payee.find_by(ynab_id: item.id)&.destroy
        else
          record = Payee.find_or_initialize_by(ynab_id: item.id)

          record.assign_attributes(
            plan_id: plan_id,
            name: item.name,
            transfer_account_id: item.transfer_account_id,
            deleted: item.deleted
          )
          record.save!


        end
      end

      knowledge_record.update!(knowledge: data.server_knowledge)
    end

  rescue StandardError => e
    Rails.logger.error("YnabPayeeSyncJob failed for plan_id #{plan_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise e
  end
end
