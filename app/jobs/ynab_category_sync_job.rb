class YnabCategorySyncJob < ApplicationJob
  queue_as :default

  def perform(plan_id)
    ynab = Ynab::ClientService.new.client

    knowledge_record = ServerKnowledge.find_or_initialize_by(plan_id: plan_id, topic: "categories")
    last_knowledge = knowledge_record.knowledge

    response = if last_knowledge
                 ynab.categories.get_categories(plan_id, last_knowledge_of_server: last_knowledge)
    else
                 ynab.categories.get_categories(plan_id)
    end

    data = response.data

    ActiveRecord::Base.transaction do
      data.category_groups.each do |item|
        if item.deleted
          CategoryGroup.find_by(ynab_id: item.id)&.destroy
        else
          record = CategoryGroup.find_or_initialize_by(ynab_id: item.id)

          record.assign_attributes(
            plan_id: plan_id,
            name: item.name,
            hidden: item.hidden,
            deleted: item.deleted
          )
          record.save!

          if item.respond_to?(:categories) && item.categories.present?
            item.categories.each do |c|
              if c.deleted
                Category.find_by(ynab_id: c.id)&.destroy
              else
                category = Category.find_or_initialize_by(ynab_id: c.id)
                category.assign_attributes(
                  plan_id: plan_id,
                  category_group_id: item.id,
                  name: c.name,
                  hidden: c.hidden,
                  budgeted: c.budgeted,
                  activity: c.activity,
                  balance: c.balance,
                  deleted: c.deleted
                )
                category.save!
              end
            end
          end
        end
      end

      knowledge_record.update!(knowledge: data.server_knowledge)
    end

  rescue StandardError => e
    Rails.logger.error("YnabCategorySyncJob failed for plan_id #{plan_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise e
  end
end
