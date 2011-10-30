# Control Mindstorms NXT via Bluetooth or USB
# Copyright (C) 2006-2009 Tony Buser <tbuser@gmail.com> - http://tonybuser.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

require "nxt/commands/mixins/motor"

# Implements the "Move" block in NXT-G
class Commands::Move
  include Commands::Mixins::Motor

  attr_reader   :ports
  attr_accessor :direction
  attr_accessor :left_motor, :right_motor
  attr_accessor :power
  attr_accessor :next_action

  def initialize(nxt = NXT.new($DEV))
    @nxt          = nxt

    # defaults the same as NXT-G
    @ports        = [:b, :c]
    @direction    = :forward
    @power        = 75
    @duration     = { :rotations => 1 }
    @next_action  = :brake

    self.turn_ratio = :straight
  end

  def ports=(value)
    # make it flexible, let them specify just :a, or "A", or :a,:b to do two etc.
    case value.class.to_s
      when "Symbol" then @ports = [value]
      when "String" then @ports = [value.to_sym]
      when "Array"  then @ports = value
      else raise "Invalid port type #{value.class}. Must be a Symbol, String or Array."
    end

    if @ports.include?(:a) and @ports.include?(:b) and @ports.include?(:c)
      @ports = [:all]
    end
  end

  def turn_ratio=(turn_ratio)
    # simplified steering... if the user wants fine control, they should just specify -100 to 100
    case turn_ratio
      when :straight then @turn_ratio = 0
      when :spin_left then @turn_ratio = -100
      when :spin_right then @turn_ratio = 100
      when :left then @turn_ratio = -50
      when :right then @turn_ratio = 50
      else @turn_ratio = turn_ratio
    end
  end

  def turn_ratio
    if @ports.size > 1
      @turn_ratio
    else
      0
    end
  end

  # execute the Move command based on the properties specified
  def start
    (@ports == [:all] ? [:a, :b, :c] : @ports).each do |p|
      @nxt.reset_motor_position(NXT.const_get("MOTOR_#{p.to_s.upcase}"))
    end

    if @direction == :stop
      motor_power = 0
      mode        = NXT::COAST
      run_state   = NXT::MOTOR_RUN_STATE_IDLE
    else
      motor_power = (@direction == :forward ? @power : -@power)
      mode        = NXT::MOTORON | NXT::BRAKE
      run_state   = NXT::MOTOR_RUN_STATE_RUNNING
    end

    if @ports.size == 2 || @ports == [:all]
      mode |= NXT::REGULATED
      reg_mode = NXT::REGULATION_MODE_MOTOR_SYNC
    else
      reg_mode = NXT::REGULATION_MODE_IDLE
    end

    @ports.each do |p|
      @nxt.set_output_state(
        NXT.const_get("MOTOR_#{p.to_s.upcase}"),
        motor_power,
        mode,
        reg_mode,
        turn_ratio,
        run_state,
        tacho_limit
      )
    end

    unless @duration.nil?
      if @duration[:seconds]
        sleep(@duration[:seconds])
      else
        until self.run_state[@ports[0]] == NXT::MOTOR_RUN_STATE_IDLE
          sleep(0.25)
        end
      end
      self.stop
    end
  end

  # stop the Move command based on the next_action property
  def stop

    if @next_action == :brake
      @ports.each do |p|
        @nxt.set_output_state(
          NXT.const_get("MOTOR_#{p.to_s.upcase}"),
          0,
          NXT::MOTORON | NXT::BRAKE | NXT::REGULATED,
          NXT::REGULATION_MODE_MOTOR_SPEED,
          0,
          NXT::MOTOR_RUN_STATE_RUNNING,
          0
        )
      end
    else
      @ports.each do |p|
        @nxt.set_output_state(
          NXT.const_get("MOTOR_#{p.to_s.upcase}"),
          0,
          NXT::COAST,
          NXT::REGULATION_MODE_IDLE,
          0,
          NXT::MOTOR_RUN_STATE_IDLE,
          0
        )
      end
    end
  end

  # attempt to return the output_state requested
  def method_missing(cmd)
    states = {}
    @ports.each do |p|
      states[p] = @nxt.get_output_state(NXT.const_get("MOTOR_#{p.to_s.upcase}"))[cmd]
    end
    states
  end

  # Aliases
  alias :port= :ports=
  alias :steering= :turn_ratio=
  alias :steering :turn_ratio
end
