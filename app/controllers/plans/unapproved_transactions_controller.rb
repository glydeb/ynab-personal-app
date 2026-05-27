module Plans
  class UnapprovedTransactionsController < ApplicationController
    before_action :set_plan

    def index
      order_string = "#{sort_column} #{sort_direction}"
      
      # If primary sort isn't date or amount, append the secondary sort
      unless %w[ynab_transactions.date ynab_transactions.amount].include?(sort_column)
        sec_sort_col = secondary_sort_column
        sec_sort_dir = "desc" # Defaulting secondary to desc makes sense for amounts and dates
        order_string += ", #{sec_sort_col} #{sec_sort_dir}"
      end

      base_query = @plan.ynab_transactions
                        .includes(:account, :payee, :category)
                        .references(:account, :payee, :category)
                        .order(order_string)

      @uncategorized = base_query.uncategorized_unapproved
      @pre_categorized = base_query.pre_categorized_unapproved
    end

    def sync
      YnabTransactionSyncJob.perform_now(@plan.ynab_id)
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

    def secondary_sort_column
      %w[date amount].include?(params[:secondary_sort]) ? "ynab_transactions.#{params[:secondary_sort]}" : "ynab_transactions.amount"
    end
  end
end
