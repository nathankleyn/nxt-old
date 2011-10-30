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

# Implements the "Touch Sensor" block in NXT-G
class Commands::TouchSensor < Commands::Sensor

  def initialize(nxt)
    @nxt      = nxt

    # defaults the same as NXT-G
    @port   = 1
    @trigger_point = :pressed
    set_mode
  end

  def trigger_point=(trigger_point)
    @trigger_point = trigger_point
    set_mode
  end

  def comparison=(op)
  	raise NotImplementedError, "Cannot assign a comparison operator for this sensor type."
  end

  # returns true or false based on trigger_point type
  def logic
    case @trigger_point
      when :pressed
        value_scaled > 0 ? true : false
      when :released
        value_scaled > 0 ? false : true
      when :bumped
        value_scaled > 0 ? true : false
    end
  end

  # returns the raw value of the sensor
  def raw_value
    value_raw
  end

  # resets the value_scaled property, use this to reset the sensor when in :bumped mode
  def reset
    @nxt.reset_input_scaled_value(NXT.const_get("SENSOR_#{@port}"))
  end

  # sets up the sensor port
  def set_mode
    @trigger_point == :bumped ? mode = NXT::PERIODCOUNTERMODE : mode = NXT::BOOLEANMODE
    @nxt.set_input_mode(
      NXT.const_get("SENSOR_#{@port}"),
      NXT::SWITCH,
      mode
    )
  end

  # attempt to return the input_value requested
  def method_missing(cmd)
    @nxt.get_input_values(NXT.const_get("SENSOR_#{@port}"))[cmd]
  end
end
