require_relative 'open_ai_api_client'

module Captrb
  class CompletionsClient < OpenAIApiClient
    def initialize(api_key)
      super(api_key, 'https://api.openai.com/v1/chat/completions')
    end

    def get_completion(categories, note)
      system_message = "Respond with a list of comma separated values.\nRespond like this:\ncategory1,category2,category3\n\n"
      user_message = "Please categorize the following note with three categories from the provided list of categories.\ncategories = #{categories.inspect}\nnote = \"#{note}\""
    
      messages = [
        { role: 'system', content: system_message },
        { role: 'user', content: user_message }
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
    
      response_data = make_request(payload)
    
      api_response = response_data['choices'][0]['message']['content'].strip
      if api_response =~ /^(\w+,\s*)+\w+$/
        categories_suggested = api_response.split(',').map(&:strip)
        return categories_suggested
      else
        return 'Invalid API response format'
      end
    end
    
  end
end