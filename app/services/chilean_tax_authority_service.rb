# frozen_string_literal: true

require "digest"
require "openssl"
require "net/http"
require "uri"
require "json"
require "time"

class ChileanTaxAuthorityService
  # AWS Configuration
  aws_credentials = Rails.application.credentials[:aws]

  AWS_CONFIG = {
    access_key_id: aws_credentials[:access_key_id],
    secret_access_key: aws_credentials[:secret_access_key],
    session_token: aws_credentials[:session_token],
    region: "us-east-1"
  }.freeze

  API_CONFIG = {
    host: "cn68i6qm0g.execute-api.us-east-1.amazonaws.com",
    path: "/prod/api/dte/documentos/generar",
    service: "execute-api"
  }.freeze

  class << self
    # Main method to generate a tax document
    def generate_document(price_item)
      signed_request = create_signed_request(price_item)
      make_api_request(signed_request)
    end

    private

    # Create AWS signature v4 signed request
    def create_signed_request(price_item)
      method = "POST"

      # Create timestamp
      now = Time.now.utc
      amz_date = now.strftime("%Y%m%dT%H%M%SZ")
      date_stamp = now.strftime("%Y%m%d")

      # Create request body
      request_body = build_request_body(price_item)

      # Create canonical request
      payload_hash = Digest::SHA256.hexdigest(request_body)

      headers = {
        "host" => API_CONFIG[:host],
        "x-amz-date" => amz_date,
        "x-amz-security-token" => AWS_CONFIG[:session_token]
      }

      signed_headers = "host;x-amz-date;x-amz-security-token"
      canonical_headers = "host:#{API_CONFIG[:host]}\nx-amz-date:#{amz_date}\nx-amz-security-token:#{AWS_CONFIG[:session_token]}\n"

      canonical_request = "#{method}\n#{API_CONFIG[:path]}\n\n#{canonical_headers}\n#{signed_headers}\n#{payload_hash}"

      # Create string to sign
      algorithm = "AWS4-HMAC-SHA256"
      credential_scope = "#{date_stamp}/#{AWS_CONFIG[:region]}/#{API_CONFIG[:service]}/aws4_request"
      string_to_sign = "#{algorithm}\n#{amz_date}\n#{credential_scope}\n#{Digest::SHA256.hexdigest(canonical_request)}"

      # Calculate signature
      signing_key = get_signature_key(AWS_CONFIG[:secret_access_key], date_stamp, AWS_CONFIG[:region], API_CONFIG[:service])
      signature = OpenSSL::HMAC.hexdigest("SHA256", signing_key, string_to_sign)

      # Create authorization header
      authorization_header = "#{algorithm} Credential=#{AWS_CONFIG[:access_key_id]}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"

      {
        url: "https://#{API_CONFIG[:host]}#{API_CONFIG[:path]}",
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

    # Generate AWS signature key
    def get_signature_key(key, date_stamp, region_name, service_name)
      k_date = OpenSSL::HMAC.digest("SHA256", "AWS4#{key}", date_stamp)
      k_region = OpenSSL::HMAC.digest("SHA256", k_date, region_name)
      k_service = OpenSSL::HMAC.digest("SHA256", k_region, service_name)
      OpenSSL::HMAC.digest("SHA256", k_service, "aws4_request")
    end

    # Build the request body for the Chilean tax document
    def build_request_body(price_item)
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
        Rails.logger.info "Chilean Tax Authority request successful: #{result}"
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
  end
end
