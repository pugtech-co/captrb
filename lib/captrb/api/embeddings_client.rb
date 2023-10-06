require_relative 'open_ai_api_client'

module Captrb
  class EmbeddingsClient < OpenAIApiClient
    def initialize(api_key)
      super(api_key, 'https://api.openai.com/v1/embeddings')
    end

    def get_embedding(note)
      payload = {
        input: note,
        model: 'text-embedding-ada-002'
      }
      response_data = make_request(payload)
      response_data['data'][0]['embedding']
    end
  end
end