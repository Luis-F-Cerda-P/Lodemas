class MeliApiClient
  BASE_URL = "https://api.mercadolibre.com"
  MPAGO_URL = "https://api.mercadopago.com/v1/"

  def initialize(meli_account)
    @meli_account = meli_account
    @auth_token = meli_account.meli_auth_token
    refresh_token_if_expired!
  end

  def get(path, options = {})
    sleep(0.2)

    options[:mercadopago] ||= false
    options[:optional_headers] ||= {}
    options[:expect_binary] ||= false

    base = options[:mercadopago] ? MPAGO_URL : BASE_URL
    uri = URI.join(base, path)
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{@auth_token.access_token}"

    # Add custom headers if provided
    (options[:optional_headers] || {}).each do |header, value|
      request[header.to_s] = value
    end

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("Meli API Error: #{response.code} #{response.body}")
      raise "Meli API Error: #{response.code}"
    end

    return response.body if options[:expect_binary]

    JSON.parse(response.body)
  end

  private

  def refresh_token_if_expired!
    if @auth_token.expires_at < Time.current
      @auth_token.refresh!
    end
  end
end
