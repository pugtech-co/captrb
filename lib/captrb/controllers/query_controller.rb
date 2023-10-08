require 'curses'

require_relative 'application_controller'
require_relative '../views/query_view'
require_relative '../database'

module Captrb
  class QueryController < ApplicationController
    def initialize(db, completions_api, embeddings_api, all_categories, calc, query_string)
      super()
      @query_view = QueryView.new(Curses.lines - 2, Curses.cols, 1, 0)
      @db = db
      @completions_api = completions_api
      @embeddings_api = embeddings_api
      @all_categories = all_categories
      @query_string = query_string
      @calc = calc
    end

    def render
      super
      @query_view.render(@query_string, oop().first(10))
    end

    def handle_input
      while (ch = @query_view.window.getch) != 'q'; end
    end

    def close
      super
      @query_view.close
    end

    private
    
    def oop()
      query_embedding = @embeddings_api.get_embedding(@query_string)

      # Collect embeddings and their corresponding note IDs
      note_embeddings = {}
      notes = @db.get_all_notes
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
        note_texts[index] = notes.find { |note| note[0] == note_id }[1] + " (" +top_scores[index].to_s + ")"
      end

      return note_texts
    end
  end
end