
require 'nxt/commands/mixins/sensor'

class Commands::Sensor
  include Commands::Mixins::Sensor

  attr_reader :port
  attr_accessor :trigger_point
end
