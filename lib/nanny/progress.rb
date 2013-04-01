require 'active_support/core_ext/enumerable'

module Nanny
  class Progress

    attr_reader :childs
    attr_reader :my_todo
    attr_reader :my_done
    attr_reader :parent

    def initialize(parent = nil, &block)
      @listener = block
      @parent = parent
      @my_todo = 0
      @my_done = 0
      @childs = []
    end

    def step
      todo(1)
      result = yield
      done!(1)
      result
    end

    def todo(n)
      @my_todo += n
      notify!
    end

    def done!(n)
      @my_done += n
      notify!
    end

    def complete!
      if @my_done != my_todo
        @my_done = my_todo
        childs.each(&:complete!)
        notify!
      end
    end

    def child
      Progress.new(self).tap do |child|
        @childs << child
      end
    end

    def total_todo
      my_todo + childs.sum(&:total_todo)
    end

    def total_done
      my_done + childs.sum(&:total_done)
    end

    def notify!
      parent.notify! if parent
      @listener.call(self) if @listener
    end

  end
end

