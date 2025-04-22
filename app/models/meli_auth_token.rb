require "net/http"
require "uri"
require "json"
require "ostruct"

class MeliAuthToken < ApplicationRecord
  encrypts :access_token
  encrypts :refresh_token

  belongs_to :meli_account

  def refresh!
    uri = URI("https://api.mercadolibre.com/oauth/token")
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request["Accept"] = "application/json"

    params = {
      grant_type: "refresh_token",
      client_id: Rails.application.credentials.dig(:meli, :app_id),
      client_secret: Rails.application.credentials.dig(:meli, :client_secret),
      refresh_token: self.refresh_token
    }

    request.body = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    begin
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        update(
          access_token: data["access_token"],
          expires_at: Time.current + (data["expires_in"] - 1800).seconds,
          refresh_token: data["refresh_token"]
        )
      else
        Rails.logger.error "Token refresh failed: #{response.body}"
        nil
      end
    rescue => e
      Rails.logger.error "Exception during token refresh: #{e.message}"
      nil
    end
  end
end
