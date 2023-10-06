require 'net/http'
require 'json'
require 'uri'

module Captrb
  class OpenAIApiClient
    def initialize(api_key, endpoint_uri)
      @api_key = api_key
      @uri = URI.parse(endpoint_uri)
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
    end

    protected

    def make_request(payload)
      request = Net::HTTP::Post.new(@uri.request_uri, {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@api_key}"
      })
      request.body = payload.to_json
      response = @http.request(request)
      
      return 'API Error' unless response.code == '200'
      JSON.parse(response.body)
    end
  end
end