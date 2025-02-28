# frozen_string_literal: true
require 'logger'

module DebugLogger
  DEBUG = ENV['DEBUG']
  def log(message)
    return unless DEBUG

    logger.add Logger::INFO, message
  end

  def logger
    @logger ||= Logger.new($stdout)
  end
end
