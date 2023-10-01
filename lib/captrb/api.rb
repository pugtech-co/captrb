require 'net/http'
require 'json'
require 'uri'

module Captrb
  class APIManager
    def initialize(api_key)
      @api_key = api_key
      @uri = URI.parse('https://api.openai.com/v1/chat/completions')
      @http = Net::HTTP.new(@uri.host, @uri.port)
      @http.use_ssl = true
    end

    def get_completion(categories, note)
      request = Net::HTTP::Post.new(@uri.request_uri, {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{@api_key}"
      })
      
      system_message = "Respond with a list of comma separated values.\nRespond like this:\ncategory1,category2,category3\n\n"
      user_message = "Please categorize the following note with three categories from the provided list of categories.\ncategories = #{categories.inspect}\nnote = \"#{note}\""
      assistant_message = "personal, family, work" # Replace this as needed

      messages = [
        { role: 'system', content: system_message },
        { role: 'user', content: user_message },
        { role: 'assistant', content: assistant_message }
      ]

      payload = {
        model: 'gpt-3.5-turbo',
        messages: messages,
        temperature: 0.3,
        max_tokens: 256,
        top_p: 1,
        frequency_penalty: 0,
        presence_penalty: 0
      }
      
      request.body = payload.to_json
      response = @http.request(request)
      
      return 'API Error' unless response.code == '200'

      json_data = JSON.parse(response.body)
      api_response = json_data['choices'][0]['message']['content'].strip
      if api_response =~ /^(\w+,\s*)+\w+$/
        # Split the string by comma and remove leading/trailing spaces
        categories_suggested = api_response.split(',').map(&:strip)
        return categories_suggested
      else
        return 'Invalid API response format'
      end
    end
  end
end