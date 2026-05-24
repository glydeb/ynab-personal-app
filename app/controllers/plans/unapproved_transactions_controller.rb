module Plans
  class UnapprovedTransactionsController < ApplicationController
    before_action :set_plan

    def index
      base_query = @plan.ynab_transactions
                        .includes(:account, :payee, :category)
                        .references(:account, :payee, :category)
                        .order("#{sort_column} #{sort_direction}")

      @uncategorized = base_query.uncategorized_unapproved
      @pre_categorized = base_query.pre_categorized_unapproved
    end

    def sync
      YnabTransactionSyncJob.perform_now(@plan.id)
      flash[:notice] = "Transactions successfully synchronized with YNAB."
      redirect_to plan_unapproved_transactions_path(@plan)
    end

    def approve
      transaction_ids = params[:transaction_ids] || []
      transactions = @plan.ynab_transactions.where(id: transaction_ids)

      if transactions.any?
        service = Ynab::BulkUpdateService.new(@plan)
        if service.approve_transactions(transactions)
          flash[:notice] = "Successfully approved #{transactions.count} transactions."
        else
          flash[:alert] = "Failed to communicate with YNAB API. Please try again."
        end
      else
        flash[:alert] = "No transactions were selected."
      end

      redirect_to plan_unapproved_transactions_path(@plan)
    end

    private

    def set_plan
      @plan = Plan.find(params[:plan_id])
    end

    def sort_column
      allowed_columns = {
        "date" => "ynab_transactions.date",
        "amount" => "ynab_transactions.amount",
        "account" => "accounts.name",
        "payee" => "payees.name",
        "category" => "categories.name"
      }

      allowed_columns[params[:sort]] || "ynab_transactions.date"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
  end
end
