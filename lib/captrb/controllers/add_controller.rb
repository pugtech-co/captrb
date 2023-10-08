require 'curses'

require_relative 'application_controller'
require_relative '../views/add_view'
require_relative '../database'

module Captrb
  class NotesController < ApplicationController
    def initialize(db, completions_api, embeddings_api, all_categories)
      super()
      @add_view = AddView.new(Curses.lines - 2, Curses.cols, 1, 0)
      @db = db
      @completions_api = completions_api
      @embeddings_api = embeddings_api
      @all_categories = all_categories
    end

    def render
      super
      @add_view.render(@db.get_all_notes_text.last(10))
    end

    def handle_input
      @add_view.window.attron(Curses::A_BOLD)
      @add_view.window.attron(Curses.color_pair(2))
      @add_view.window.addstr("\nEnter your note: ")
      @add_view.window.attroff(Curses.color_pair(2))
      @add_view.window.attroff(Curses::A_BOLD)
      note_text = @add_view.window.getstr
      if note_text == 'q'
        return
      end
      completion, embedding = get_note note_text

      if completion == nil
        return
      end

      save_note note_text, completion, embedding
      handle_input
    end

    def close
      super
      @add_view.close
    end

    private

    def get_note(note_text)
      completion = @completions_api.get_completion(note_text, @all_categories)
      embedding = @embeddings_api.get_embedding(note_text)

      # TODO how to give this to the view?
      if completion.is_a?(Array)
        @add_view.window.attron(Curses.color_pair(2))
        @add_view.window.addstr "API Suggested Categories: #{completion.join(', ')}"
        @add_view.window.attroff(Curses.color_pair(2))
      elsif completion.is_a?(String)
        puts "API Completion Doesn't match expected pattern: #{completion}"
        return nil, nil
      end
      return completion, embedding
    end

    def save_note(note_text, categories, embedding)
      note_id = @db.add_note(note_text)
      categories.each do |category|
        @db.add_category(note_id, category)
      end
      @db.add_embedding(note_id, embedding)
    end
  end
end