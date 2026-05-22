module Ynab
  class ClientService
    def initialize
      # Pulls the Personal Access Token strictly from the Rails encrypted credentials vault
      # as mandated by the Security Infrastructure guidelines.
      @access_token = Rails.application.credentials.ynab_access_token!

      @client = YNAB::API.new(@access_token)
    end

    def client
      @client
    end
  end
end
