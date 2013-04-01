require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/hash/keys'

module Nanny
  module AttrInitializer
    def initialize(opts = {})
      opts.each do |opt, val|
        instance_variable_set("@#{opt}", val) if respond_to? opt
      end
    end
  end
end

