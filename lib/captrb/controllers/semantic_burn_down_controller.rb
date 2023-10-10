# the burn down view should show the item, the recommended items, and options for completion
# Or it should show all items completed.

require 'curses'

require_relative 'application_controller'
require_relative '../database'

module Captrb
  class SemanticBurnDownController < BurnDownController
    def initialize(db, completions_api, embeddings_api, all_categories, calc, query_string)
      super(db, completions_api, embeddings_api, all_categories, calc)
      @query_string = query_string
    end

    def notes_query
      query_embedding = @embeddings_api.get_embedding(@query_string)

      # Collect embeddings and their corresponding note IDs
      note_embeddings = {}
      notes = @db.get_all_notes_with_categories
      notes.each do |note|
        note_id = note[0]
        embedding = @db.get_embedding(note_id)
        note_embeddings[note_id] = embedding if embedding
      end
    
      # sort notes by cosine similarity to query
      top_note_ids, top_scores = @calc.strings_ranked_by_relatedness(query_embedding, note_embeddings)
    
      note_texts = []
      # Print or otherwise use the top related notes
      top_note_ids.each_with_index do |note_id, index|
        note_texts[index] = notes.find { |note| note[0] == note_id }
        note_texts[index] << @db.get_categories_by_note_id(note_id)
        note_texts[index][1] += " (" + (top_scores[index] * 100).round().to_s + "% match)"
      end

      note_texts
    end
  end
end