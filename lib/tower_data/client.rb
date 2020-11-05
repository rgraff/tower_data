require 'timeout'
require "faraday"
require "json"

module TowerData
  class Client
    def bulk_intelligence(emails)
      payload = Array(emails).map {|email| {email: email} }
      bulk_query(payload)
    end

    def intelligence(email:, fields: nil)
      query(email: email, fields: fields)
    end

    def validation(email:)
      intelligence(
        email: email,
        fields: 'email_validation'
      )[:email_validation]
    end
    alias validate validation

    private

    def connection
      @connection ||= Faraday.new(url: "https://api.towerdata.com") { |conn|
        conn.headers['Content-Type'] = 'application/json;charset=utf-8'
        conn.adapter Faraday.default_adapter
      }
    end

    def query(timeout: 5, **params)
      response = Timeout.timeout(timeout, TowerData::TimeoutError) {
        connection.get { |req|
          req.url base_path
          req.params.merge!(params)
          req.params['api_key'] = api_key
        }
      }

      handle_response(response)
    end

    def bulk_query(data, timeout: 5)
      response = Timeout.timeout(timeout, TowerData::TimeoutError) {
        connection.post { |req|
          req.url bulk_path
          req.body = data.to_json
          req.params['api_key'] = api_key
        }
      }

      handle_response(response)
    end

    def handle_response(response)
      case response.status
      when (200..299)
        body = JSON.parse(response.body)
        case body
        when Array
          body.map{|h| h.transform_keys(&:to_sym) }
        when Hash
          body.transform_keys(&:to_sym)
        end
      when 400
        raise TowerData::BadRequest, response.body
      else
        raise TowerData::ApiError, "Error Code #{response.status}: \"#{response.body}\""
      end
    end

    def bulk_path
      '/v5/ei/bulk'
    end

    def base_path
      '/v5/td'
    end

    def api_key
      ENV['TOWERDATA_API_KEY']
    end
  end
end
