require_relative 'config/environment'
client = Ynab::ClientService.new.client
puts client.budgets.get_budgets.data.to_json
