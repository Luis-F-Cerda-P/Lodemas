require "digest"
require "openssl"
require "net/http"
require "uri"
require "json"
require "time"
require "base64"

class SiiApiClient
  # TODO: Convertir los métodos que se refieren a autorización en métodos privados. Deberían estar envueltos en una rutina de autorización o ser responsabilida de cada "set" (token_set, credentia_set) su propia rutina de obtención y refresco.
  # TODO: El procesamiento de los JWT debe extraerse, porque además del sign-in y refresco los procesa y guarda de la misma forma.
  # TODO: La única diferencia relevante entre los request es su cuerpo, por tanto debería extraerse la creación del request como plantilla y en sign_in y exchange simplemente asignarles el cuerpo correcto.
  BASE_AWS_CONFIG = {
    region: "us-east-1"
  }.freeze
  # TODO: Estos valores luego serán métodos de la clase que buscarán los valores actualizados
  BILLING_API_CONFIG = {
    host: "cn68i6qm0g.execute-api.us-east-1.amazonaws.com",
    path: "/prod/api/dte/documentos/generar",
    service: "execute-api"
  }.freeze

  SII_SIGN_IN_URL = "https://x78kr8nqx5.execute-api.us-east-1.amazonaws.com/prod/sign-in"
  SII_REFRESH_TOKEN_URL = "https://x78kr8nqx5.execute-api.us-east-1.amazonaws.com/prod/refresh-token"
  COGNITO_CREDENTIALS_URL = "https://cognito-identity.us-east-1.amazonaws.com/"

  def initialize(tax_account)
    @tax_account = tax_account
    @aws_credentials = BASE_AWS_CONFIG.merge(get_valid_aws_credential_set.attributes)
  end

  def generate_bill_by_amount(amount)
    request_body = build_bill_request_body(amount)
    signed_request = create_signed_request(request_body)
    bill_json = make_api_request(signed_request)

    bill_json
  end

  def sign_in
    url = URI(SII_SIGN_IN_URL)

    rut = @tax_account.rut[0...-1]
    dv = @tax_account.rut[-1]
    password = @tax_account.password

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json; charset=UTF-8"
    request["accept"] = "application/json, text/plain, */*"
    request["accept-language"] = "en-US,en;q=0.9"
    request["cache-control"] = "no-cache"
    request["origin"] = "https://eboleta.sii.cl"
    request["pragma"] = "no-cache"
    request["priority"] = "u=1, i"
    request["referer"] = "https://eboleta.sii.cl/"
    request["sec-ch-ua"] = "\"Chromium\";v=\"136\", \"Google Chrome\";v=\"136\", \"Not.A/Brand\";v=\"99\""
    request["sec-ch-ua-mobile"] = "?0"
    request["sec-ch-ua-platform"] = "\"Windows\""
    request["sec-fetch-dest"] = "empty"
    request["sec-fetch-mode"] = "cors"
    request["sec-fetch-site"] = "cross-site"
    request["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36"

    request.body = {
      "rut" => rut,
      "dv" => dv,
      "clave" => password,
      "opts" => nil
    }.to_json

    response = https.request(request)
    json = JSON.parse(response.read_body)

    access_token = json["jwt"]["accessToken"]
    refresh_token = json["jwt"]["refreshToken"]
    aws_token = json["openId"]["Token"]
    identity_id = json["openId"]["IdentityId"]
    access_token_expires_at = Time.at(JSON.parse(Base64.urlsafe_decode64(access_token.split(".")[1]))["exp"])
    refresh_token_expires_at = Time.at(JSON.parse(Base64.urlsafe_decode64(refresh_token.split(".")[1]))["exp"])
    aws_token_expires_at = Time.at(JSON.parse(Base64.urlsafe_decode64(aws_token.split(".")[1]))["exp"])


    jwt_token_set = JwtTokenSet.find_or_initialize_by(tax_account_id: @tax_account.id)
    jwt_token_set.assign_attributes(
      access_token: access_token,
      refresh_token: refresh_token,
      aws_token: aws_token,
      access_token_expires_at: access_token_expires_at,
      refresh_token_expires_at: refresh_token_expires_at,
      aws_token_expires_at: aws_token_expires_at,
      identity_id: identity_id,
    )
    jwt_token_set.save!
  end

  def refresh_jwt_token_set
    jwt_token_set = @tax_account.jwt_token_set
    if jwt_token_set.refresh_token_expired? || jwt_token_set.refresh_token.nil?
      sign_in
    else
      url = URI(SII_REFRESH_TOKEN_URL)

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["Content-Type"] = "application/json; charset=UTF-8"
      request["accept"] = "application/json, text/plain, */*"
      request["accept-language"] = "en-US,en;q=0.9"
      request["cache-control"] = "no-cache"
      request["origin"] = "https://eboleta.sii.cl"
      request["pragma"] = "no-cache"
      request["priority"] = "u=1, i"
      request["referer"] = "https://eboleta.sii.cl/"
      request["sec-ch-ua"] = "\"Chromium\";v=\"136\", \"Google Chrome\";v=\"136\", \"Not.A/Brand\";v=\"99\""
      request["sec-ch-ua-mobile"] = "?0"
      request["sec-ch-ua-platform"] = "\"Windows\""
      request["sec-fetch-dest"] = "empty"
      request["sec-fetch-mode"] = "cors"
      request["sec-fetch-site"] = "cross-site"
      request["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36"

      request.body = {
        "accessToken": jwt_token_set.access_token,
        "refreshToken": jwt_token_set.refresh_token
      }.to_json

      response = https.request(request)
      json = JSON.parse(response.read_body)

      access_token = json["jwt"]["accessToken"]
      refresh_token = json["jwt"]["refreshToken"]
      aws_token = json["openId"]["Token"]
      identity_id = json["openId"]["IdentityId"]
      access_token_expires_at = Time.at(JSON.parse(Base64.urlsafe_decode64(access_token.split(".")[1]))["exp"])
      refresh_token_expires_at = Time.at(JSON.parse(Base64.urlsafe_decode64(refresh_token.split(".")[1]))["exp"])
      aws_token_expires_at = Time.at(JSON.parse(Base64.urlsafe_decode64(aws_token.split(".")[1]))["exp"])


      jwt_token_set = JwtTokenSet.find_or_initialize_by(tax_account_id: @tax_account.id)
      jwt_token_set.assign_attributes(
        access_token: access_token,
        refresh_token: refresh_token,
        aws_token: aws_token,
        access_token_expires_at: access_token_expires_at,
        refresh_token_expires_at: refresh_token_expires_at,
        aws_token_expires_at: aws_token_expires_at,
        identity_id: identity_id,
      )

      jwt_token_set.save!
    end
  end

  def exchange_jwt_token_for_credentials
    url = URI(COGNITO_CREDENTIALS_URL)

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["accept"] = "*/*"
    request["accept-language"] = "en-US,en;q=0.9"
    request["cache-control"] = "no-store"
    request["content-type"] = "application/x-amz-json-1.1"
    request["origin"] = "https://eboleta.sii.cl"
    request["pragma"] = "no-cache"
    request["priority"] = "u=1, i"
    request["referer"] = "https://eboleta.sii.cl/"
    request["sec-ch-ua"] = "\"Chromium\";v=\"136\", \"Google Chrome\";v=\"136\", \"Not.A/Brand\";v=\"99\""
    request["sec-ch-ua-mobile"] = "?0"
    request["sec-ch-ua-platform"] = "\"Windows\""
    request["sec-fetch-dest"] = "empty"
    request["sec-fetch-mode"] = "cors"
    request["sec-fetch-site"] = "cross-site"
    request["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36"
    request["x-amz-target"] = "AWSCognitoIdentityService.GetCredentialsForIdentity"
    request["x-amz-user-agent"] = "aws-amplify/5.3.26 framework/0"

    request.body = {
      "IdentityId" => @tax_account.jwt_token_set.identity_id,
      "Logins" => {
        "cognito-identity.amazonaws.com" => @tax_account.jwt_token_set.aws_token
      }
    }.to_json

    response = https.request(request)
    json = JSON.parse(response.read_body)

    access_key_id = json["Credentials"]["AccessKeyId"]
    secret_access_key = json["Credentials"]["SecretKey"]
    session_token = json["Credentials"]["SessionToken"]
    expires_at = Time.at(json["Credentials"]["Expiration"])

    aws_credential_set = AwsCredentialSet.find_or_initialize_by(tax_account_id: @tax_account.id)

    aws_credential_set.assign_attributes(
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      session_token: session_token,
      expires_at: expires_at,
    )

    aws_credential_set.save!
  end

  # Create AWS signature v4 signed request
  def create_signed_request(request_body, null_signature: false)
    method = "POST"

    # Create timestamp >> Parte del firmado
    now = Time.now.utc
    amz_date = now.strftime("%Y%m%dT%H%M%SZ")
    date_stamp = now.strftime("%Y%m%d")
    # Create canonical request
    payload_hash = Digest::SHA256.hexdigest(request_body)

    headers = {
      "host" => BILLING_API_CONFIG[:host],
      "x-amz-date" => amz_date,
      "x-amz-security-token" => AWS_CONFIG[:session_token]
    }

    signed_headers = "host;x-amz-date;x-amz-security-token"
    canonical_headers = "host:#{BILLING_API_CONFIG[:host]}\nx-amz-date:#{amz_date}\nx-amz-security-token:#{AWS_CONFIG[:session_token]}\n"

    canonical_request = "#{method}\n#{BILLING_API_CONFIG[:path]}\n\n#{canonical_headers}\n#{signed_headers}\n#{payload_hash}"

    # Create string to sign
    algorithm = "AWS4-HMAC-SHA256"
    credential_scope = "#{date_stamp}/#{AWS_CONFIG[:region]}/#{BILLING_API_CONFIG[:service]}/aws4_request"
    string_to_sign = "#{algorithm}\n#{amz_date}\n#{credential_scope}\n#{Digest::SHA256.hexdigest(canonical_request)}"

    # Calculate signature
    secret_key = null_signature ? "" : AWS_CONFIG[:secret_access_key]
    signing_key = get_signature_key(secret_key, date_stamp, AWS_CONFIG[:region], BILLING_API_CONFIG[:service])
    signature = OpenSSL::HMAC.hexdigest("SHA256", signing_key, string_to_sign)

    # Create authorization header
    authorization_header = "#{algorithm} Credential=#{AWS_CONFIG[:access_key_id]}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"

    {
      url: "https://#{BILLING_API_CONFIG[:host]}#{BILLING_API_CONFIG[:path]}",
      method: method,
      headers: headers.merge({
        "Authorization" => authorization_header,
        "Content-Type" => "application/json",
        "accept" => "application/json, text/plain, */*",
        "accept-language" => "en-US,en;q=0.9",
        "cache-control" => "no-cache",
        "origin" => "https://eboleta.sii.cl",
        "pragma" => "no-cache",
        "referer" => "https://eboleta.sii.cl/",
        "user-agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36"
      }),
      body: request_body
    }
  end

  # Make the HTTP request
  def make_api_request(signed_request)
    uri = URI(signed_request[:url])

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Post.new(uri.path)
    signed_request[:headers].each { |key, value| request[key] = value }
    request.body = signed_request[:body]

    Rails.logger.info "Making request to Chilean Tax Authority with URL: #{signed_request[:url]}"

    response = http.request(request)

    case response
    when Net::HTTPSuccess
      result = JSON.parse(response.body)
      Rails.logger.info "Chilean Tax Authority request successful"
      result
    else
      error_body = response.body rescue "No response body"
      error_message = "Chilean Tax Authority request failed: #{response.code} #{response.message}. Body: #{error_body}"
      Rails.logger.error error_message
      raise StandardError, error_message
    end
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse Chilean Tax Authority response: #{e.message}"
    raise StandardError, "Invalid JSON response from Chilean Tax Authority"
  rescue StandardError => e
    Rails.logger.error "Chilean Tax Authority request error: #{e.message}"
    raise
  end

  # Generate AWS signature key
  def get_signature_key(key, date_stamp, region_name, service_name)
    k_date = OpenSSL::HMAC.digest("SHA256", "AWS4#{key}", date_stamp)
    k_region = OpenSSL::HMAC.digest("SHA256", k_date, region_name)
    k_service = OpenSSL::HMAC.digest("SHA256", k_region, service_name)
    OpenSSL::HMAC.digest("SHA256", k_service, "aws4_request")
  end

  # Build the request body for the Chilean tax document
  def build_bill_request_body(price_item)
    {
      "vendedor" => "25667156-5",
      "Encabezado" => {
        "IdDoc" => { "TipoDTE" => 39, "Folio" => 1 },
        "Emisor" => { "RUTEmisor" => "77268185-2", "CdgSIISucur" => 91622570 },
        "Receptor" => { "RUTRecep" => "66666666-6", "RznSocRecep" => "SII Boleta", "DirRecep" => "Santiago" }
      },
      "Detalle" => [ { "NmbItem" => "Monto Total", "QtyItem" => 1, "PrcItem" => price_item } ],
      "Meta" => {
        "info_emisor" => {
          "rut" => 77268185,
          "dv" => "2",
          "razonSocial" => "PETPORIUM SPA",
          "giro" => "COMERCIALIZACIN DE ARTCULOS PARA MASCOTAS",
          "actividadEconomica" => nil,
          "direccion" => nil,
          "nombreComuna" => nil,
          "nombreProvincia" => nil,
          "numeroResolucion" => 99,
          "fechaResolucion" => "2014-10-21",
          "secciones" => [],
          "tiposDte" => [
            { "codigo" => 39, "nombre" => "Boleta electrónica" },
            { "codigo" => 41, "nombre" => "Boleta exenta electrónica" }
          ],
          "sucursales" => [ {
            "codigo" => 91622570,
            "direccion" => "CERRO EL PLOMO 5931 OF 1213 PS 12 ",
            "nombre_comuna" => "Las Condes",
            "nombre_provincia" => "Santiago"
          } ],
          "esRepresentanteLegal" => true
        },
        "plataforma" => "eboleta_web"
      }
    }.to_json
  end

  def get_valid_jwt_token_set
    @tax_account.jwt_token_set unless @tax_account.jwt_token_set.refresh_token_expired?

    refresh_jwt_token_set

    @tax_account.jwt_token_set
  end

  def get_valid_aws_credential_set
    @tax_account.aws_credential_set unless @tax_account.aws_credential_set.expired

    get_valid_jwt_token_set
    exchange_jwt_token_for_credentials

    @tax_account.aws_credential_set
  end
end
