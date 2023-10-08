require_relative 'base_view'

module Captrb
  class AddView < BaseView
    def render(notes)
      @window.attron(Curses.color_pair(2))
      notes.each_with_index do |note, index|
        @window.setpos(index, 0)
        @window.addstr("#{index + 1}. #{note}")
      end
      @window.attroff(Curses.color_pair(2))
      @window.refresh
    end
  end
end