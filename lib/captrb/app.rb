require 'curses'
require_relative 'router'

module Captrb
  class App
    def self.start(args)

      Curses.init_screen
      Curses.start_color
      Curses.init_pair(1, Curses::COLOR_BLACK, Curses::COLOR_GREEN)
      Curses.init_pair(2, Curses::COLOR_GREEN, Curses::COLOR_BLACK)
      Curses.init_pair(3, Curses::COLOR_WHITE, Curses::COLOR_BLACK)

      controller = Captrb::Router.start(args)

      begin
        controller.render
        controller.handle_input
      rescue => e
        Curses.close_screen
        puts e.message
        puts e.backtrace
        return
      end


      Curses.close_screen

    end
  end
end