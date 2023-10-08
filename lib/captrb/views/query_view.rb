require_relative 'base_view'

module Captrb
  class QueryView < BaseView
    def render(query_string, notes)
      @window.attron(Curses.color_pair(2))
      @window.attron(Curses::A_BOLD)
      @window.addstr("Query: #{query_string}")
      @window.attroff(Curses::A_BOLD)
      notes.each_with_index do |note, index|
        @window.setpos(index+1, 0)
        @window.addstr("#{index + 1}. #{note}")
      end
      @window.attroff(Curses.color_pair(2))
      @window.refresh
    end
  end
end