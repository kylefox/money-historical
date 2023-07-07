# frozen_string_literal: true

require "money"

require_relative "historical/version"
require_relative "historical/rates_store/base"
require_relative "historical/rates_store/memory_store"

class Money
  module Historical
    class Error < StandardError; end
    # Your code goes here...
  end
end
