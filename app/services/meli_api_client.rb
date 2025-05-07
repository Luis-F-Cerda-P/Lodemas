class MeliApiClient
  BASE_URL = "https://api.mercadolibre.com"

  def initialize(meli_account)
    @meli_account = meli_account
    @auth_token = meli_account.meli_auth_token
    refresh_token_if_expired!
  end

  def get(path)
    uri = URI.join(BASE_URL, path)
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{@auth_token.access_token}"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("Meli API Error: #{response.code} #{response.body}")
      raise "Meli API Error: #{response.code}"
    end

    JSON.parse(response.body)
  end

  private

  def refresh_token_if_expired!
    if @auth_token.expires_at < Time.current
      @auth_token.refresh!
    end
  end
end
