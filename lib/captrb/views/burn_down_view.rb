require_relative 'base_view'

module Captrb
  class BurnDownView < BaseView
    def render(note, categories)
      @window.clear
      @window.attron(Curses.color_pair(2))
      @window.addstr("TODO: ")
      @window.attron(Curses::A_BOLD)
      @window.addstr("#{note}")
      @window.attroff(Curses::A_BOLD)
      @window.addstr("\n\nSuggested categories for completion: ")
      @window.attron(Curses::A_BOLD)
      @window.addstr("#{categories.join(', ')}")
      @window.attroff(Curses::A_BOLD)
      @window.attroff(Curses.color_pair(2))
      @window.attron(Curses.color_pair(3))
      @window.addstr("\n\n")
      @window.addstr("Complete (c) or Skip (s) or Quit (q)\n")
      @window.attroff(Curses.color_pair(3))
      @window.refresh
    end
  end
end