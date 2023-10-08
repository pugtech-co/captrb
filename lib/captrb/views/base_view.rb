module Captrb
  class BaseView
    attr_reader :window

    def initialize(lines, cols, y, x)
      @window = Curses::Window.new(lines, cols, y, x)
    end

    def render
      raise NotImplementedError, 'This method should be overridden by subclass'
    end

    def getch
      @window.getch
    end

    def close
      @window.close
    end
  end
end