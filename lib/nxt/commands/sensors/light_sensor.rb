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

# Implements (and extends) the "Light Sensor" block in NXT-G
class Commands::LightSensor < Commands::Sensor

  attr_reader :generate_light
  attr_accessor :comparison

  def initialize(nxt)
    @nxt      = nxt

    # defaults the same as NXT-G
    @port           = 3
    @trigger_point  = 50
    @comparison     = ">"
    @generate_light = true
    set_mode
  end

  # Turns off the sensor's LED light.
  def ambient_mode
    self.generate_light = false
  end

  # Turns on the sensor's LED light.
  def illuminated_mode
    self.generate_light = true
  end

  # Turns the sensor's LED on or off.
  # Takes true or false as the argument; if true, light will be turned on,
  # if false, light will be turned off.
  def generate_light=(on)
    @generate_light = on
    set_mode
  end

  # intensity of light detected 0-100 in %
  def intensity
    value_scaled
  end

  # returns the raw value of the sensor
  def raw_value
    value_raw
  end

  # sets up the sensor port
  def set_mode
    @generate_light ? mode = NXT::LIGHT_ACTIVE : mode = NXT::LIGHT_INACTIVE
    @nxt.set_input_mode(
      NXT.const_get("SENSOR_#{@port}"),
      mode,
      NXT::PCTFULLSCALEMODE
    )
  end

  # attempt to return the input_value requested
  def method_missing(cmd)
    @nxt.get_input_values(NXT.const_get("SENSOR_#{@port}"))[cmd]
  end

  # Aliases
  alias :light_level :intensity
end
