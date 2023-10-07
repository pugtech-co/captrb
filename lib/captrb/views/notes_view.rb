require_relative 'base_view'

module Captrb
  class NotesView < BaseView
    def render
      notes = ["Note 1", "Note 2", "Note 3"]
      @window.attron(Curses.color_pair(2))
      notes.each_with_index do |note, index|
        @window.setpos(index, 0)
        @window.addstr("#{index + 1}. #{note}")
      end
      @window.attroff(Curses.color_pair(2))
      @window.refresh
      puts "NotesView#render executed"
    end
  end
end