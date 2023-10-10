# the burn down view should show the item, the recommended items, and options for completion
# Or it should show all items completed.

require 'curses'

require_relative 'application_controller'
require_relative '../views/burn_down_view'
require_relative '../database'

module Captrb
  class BurnDownController < ApplicationController
    def initialize(db, completions_api, embeddings_api, all_categories, calc)
      super()
      @burn_down_view = BurnDownView.new(Curses.lines - 2, Curses.cols, 1, 0)
      @db = db
      @completions_api = completions_api
      @embeddings_api = embeddings_api
      @all_categories = all_categories
      @calc = calc
      @id = 1
    end

    def get_notes
      @notes = notes_query unless @notes
      return @notes
    end

    # override this in subclasses to change how notes are ordered/selected
    def notes_query
      @db.get_all_notes_with_categories
    end

    def render
      id, note, categories = get_notes[@id]
      if note.nil?
        @burn_down_view.render("All notes completed!", [])
      end  
      @burn_down_view.render(note, categories)
      super
    end
 
    # print "Complete (c) or Skip (s) or Quit (q)"
    def handle_input
      while @id < get_notes.length
        ch = @burn_down_view.window.getch
        if ch == 'q'
          return
        elsif ch == 'c'
          @id += 1
          render
        elsif ch == 's'
          @id += 1
          render
        else
          render
        end
      end
    end

    def close
      super
      @query_view.close
    end

    private
    
  end
end