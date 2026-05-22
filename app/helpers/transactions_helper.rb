module TransactionsHelper
  def format_milliunits(amount)
    return number_to_currency(0) if amount.blank?
    number_to_currency(amount / 1000.0)
  end

  def sort_link(column, title = nil)
    title ||= column.titleize

    current_sort = params[:sort] || "date"
    current_direction = params[:direction] || "desc"

    direction = current_sort == column && current_direction == "asc" ? "desc" : "asc"
    icon = sort_icon(column)

    link_to "#{title} #{icon}".html_safe, request.params.merge(sort: column, direction: direction)
  end

  def sort_icon(column)
    current_sort = params[:sort] || "date"
    current_direction = params[:direction] || "desc"

    if current_sort == column
      current_direction == "asc" ? "↑" : "↓"
    else
      ""
    end
  end

  def render_year_divider?(transaction, previous_transaction)
    current_sort = params[:sort] || "date"
    return false unless current_sort == "date"
    return false if previous_transaction.nil?

    transaction.date.year != previous_transaction.date.year
  end
end
