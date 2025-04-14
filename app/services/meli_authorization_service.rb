require "net/http"
require "uri"
require "json"
require "ostruct"

class MeliAuthorizationService
  AUTH_URL = "https://api.mercadolibre.com/oauth/token"

  def initialize(code:, current_user:)
    @code = code
    @current_user = current_user
  end


  def call
    uri = URI(AUTH_URL)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request["Accept"] = "application/json"

    params = {
      grant_type: "authorization_code",
      client_id: Rails.application.credentials.dig(:meli, :app_id),
      client_secret: Rails.application.credentials.dig(:meli, :client_secret),
      code: @code,
      redirect_uri: Rails.application.credentials.dig(:meli, :redirect_uri)
    }

    request.body = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    begin
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        create_records(JSON.parse(response.body))
      else
        OpenStruct.new(success: false, error: "Error conectando con MercadoLibre")
      end
    rescue StandardError => e
      OpenStruct.new(success: false, error: "Error conectando con MercadoLibre: #{e.message}")
    end
  end

  private

  def create_records(data)
    ActiveRecord::Base.transaction do
      account = @current_user.meli_account || @current_user.build_meli_account
      account.update!(
        mercadolibre_identifier: data["user_id"],
      )

      account.meli_auth_token&.destroy
      account.create_meli_auth_token!(
        access_token: data["access_token"],
        refresh_token: data["refresh_token"],
        expires_at: Time.current + (data["expires_in"] - 1800).seconds
      )
    end

    OpenStruct.new(success: true)
  rescue => e
    OpenStruct.new(success: false, error: e.message)
  end
end
