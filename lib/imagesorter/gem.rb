# frozen_string_literal: true

require 'logger'

module Imagesorter
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.logger=(logger)
    @logger = logger
  end

  # Gem related helpers
  module Gem
    def self.root
      @root ||= File.expand_path('../../..', __FILE__)
    end

    def self.version
      @version ||= File.read(File.join(root, 'version')).strip
    end
  end
end
