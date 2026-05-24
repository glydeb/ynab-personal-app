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
        Rails.logger.error("Failed to bulk update YNAB transactions: #{e.message}")
        false
      end
    end
  end
end
