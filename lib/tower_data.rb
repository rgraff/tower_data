require "tower_data/version"
require "tower_data/client"

module TowerData
  class Error < StandardError; end
  class TimeoutError < Error; end
  class ApiError < Error; end
  class BadRequest < Error; end

  def self.client
    Client.new
  end
end
