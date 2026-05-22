class YnabPlanSyncJob < ApplicationJob
  queue_as :default

  def perform
    ynab = Ynab::ClientService.new.client

    response = ynab.plans.get_plans
    data = response.data

    ActiveRecord::Base.transaction do
      data.plans.each do |p|
        plan = Plan.find_or_initialize_by(ynab_id: p.id)
        plan.assign_attributes(
          name: p.name,
          last_modified_on: p.last_modified_on
        )
        plan.save!
      end
    end

  rescue StandardError => e
    Rails.logger.error("YnabPlanSyncJob failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise e
  end
end
