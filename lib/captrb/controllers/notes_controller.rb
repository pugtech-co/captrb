require 'curses'

require_relative 'application_controller'
require_relative '../views/notes_view'

module Captrb
  class NotesController < ApplicationController
    def initialize
      super
      @notes_view = NotesView.new(Curses.lines - 2, Curses.cols, 1, 0)
    end

    def render
      super
      @notes_view.render
    end

    def handle_input
      while (ch = @notes_view.getch) != 'q'; end
    end

    def close
      super
      @notes_view.close
    end
  end
end