module Ynab
  class BulkUpdateService
    def initialize(plan)
      @plan = plan
      @client = ClientService.new.client
    end

    def approve_transactions(transactions)
      return true if transactions.empty?

      payload = transactions.map do |t|
        {
          id: t.ynab_id,
          approved: true,
          category_id: t.category_id
        }
      end

      wrapper = {
        transactions: payload
      }

      begin
        @client.transactions.update_transactions(@plan.ynab_id, wrapper)
        
        # Update local database synchronously to avoid waiting for the next sync job
        updated_ynab_ids = payload.map { |p| p[:id] }
        YnabTransaction.where(ynab_id: updated_ynab_ids).update_all(approved: true)
        
        true
      rescue YNAB::ApiError => e
        Rails.logger.error("YNAB API Error during bulk update: #{e.response_body}")
        false
      rescue StandardError => e
        Rails.logger.error("Failed to bulk approve transactions: #{e.message}")
        false
      end
    end

    def clear_categories(transactions)
      transactions_payload = transactions.map do |t|
        {
          id: t.ynab_id,
          category_id: nil,
          approved: false
        }
      end

      wrapper = {
        transactions: transactions_payload
      }

      response = @client.transactions.update_transactions(@plan.ynab_id, wrapper)

      if response.data.server_knowledge
        knowledge_record = ServerKnowledge.find_or_initialize_by(plan_id: @plan.ynab_id, topic: "transactions")
        knowledge_record.update!(knowledge: response.data.server_knowledge)
      end

      ActiveRecord::Base.transaction do
        transactions.each do |t|
          if t.category_id.present?
            RejectedCategory.create!(ynab_transaction_id: t.ynab_id, category_id: t.category_id)
          end
          t.update!(category_id: nil, approved: false)
        end
      end

      true
    rescue StandardError => e
      Rails.logger.error("Failed to bulk clear categories: #{e.message}")
      false
    end
  end
end
