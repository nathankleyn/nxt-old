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

$:.unshift File.dirname(File.expand_path(__FILE__))

require "pry"
require "serialport"
require "usb"
require "thread"

require "nxt/constants"
require "nxt/queue"

require "nxt/send_receive"
require "nxt/input_output"
require "nxt/sound"
require "nxt/ls"
require "nxt/file"
require "nxt/message"
require "nxt/program"

require "nxt/interfaces/base"
require "nxt/communication/base"
require "nxt/commands/base"

require "nxt/patches/array"
require "nxt/patches/bignum"
require "nxt/patches/string"

$DEV ||= true
$INTERFACE ||= nil

# = Description
#
# Low-level interface for communicating directly with the NXT via
# a Bluetooth serial port or USB.  Implements direct commands outlined in
# Appendix 2-LEGO MINDSTORMS NXT Direct Commands.pdf
#
# Not all functionality is implemented yet!
#
# For instructions on creating a bluetooth serial port connection:
# * Linux: http://juju.org/articles/2006/10/22/bluetooth-serial-port-to-nxt-in-linux
# * OSX: http://juju.org/articles/2006/10/22/bluetooth-serial-port-to-nxt-in-osx
# * Windows: http://juju.org/articles/2006/08/16/ruby-serialport-nxt-on-windows
#
# = Examples
#
# First create a new NXT object and pass the device.
#
#   @nxt = NXT.new("/dev/tty.NXT-DevB-1")
#
# Rotate the motor connected to port B forwards indefinitely at 100% power:
#
#   @nxt.set_output_state(
#     NXT::MOTOR_B,
#     100,
#     NXT::MOTORON,
#     NXT::REGULATION_MODE_MOTOR_SPEED,
#     100,
#     NXT::MOTOR_RUN_STATE_RUNNING,
#     0
#   )
#
# Play a tone at 1000 Hz for 500 ms:
#
#   @nxt.play_tone(1000,500)
#
# Print out the current battery level:
#
#   puts "Battery Level: #{@nxt.get_battery_level/1000.0} V"
#

module NXT
  class NXT
    include Mixins::Consts
    include Mixins::Queue

    @@mutex = Mutex.new

    attr_accessor :dev

    # Create a new instance of NXT.
    # Be careful not to create more than one NXT object per serial port dev.
    # If two NXTs try to talk to the same dev, there will be trouble.
    def initialize(connection)

      @dev = dev

      @@mutex.synchronize do
        begin
          @connection = connection
          @connection.connect
        rescue Exception => e
          raise "NXT#intialize: Cannot connect. The device is busy or unavailable."
        end
      end

      puts "Connected to: #{@connection.inspect}" if $DEBUG
    end

    # Close the connection
    def close
      @@mutex.synchronize do
        @connection.close
      end
    end

    # Returns true if the connection to the NXT is open; false otherwise
    def connected?
      @connection.connected?
    end

    # Keep the connection alive and prevents NXT from going to sleep until sleep time.  Also, returns the current sleep time limit in ms
    def keep_alive
      result = send_and_receive(@@op_codes["keep_alive"], [])
      result == false ? false : result.join.from_hex_str.unpack("L")[0]
    end

    # Returns a hash of information about the nxt:
    #  {
    #    :name    => name of the brick,
    #    :address => bluetooth mac address,
    #    :signal  => bluetooth signal strength, for some reason always returns 0?
    #    :free    => free space on flash in bytes
    #  }
    def get_device_info
      result = send_and_receive(@@op_codes["get_device_info"], [])
      if result
        parts = result.join.from_hex_str.unpack("Z15C7VV")
        {
          :name     => parts[0],
          :address  => parts[1..6].collect{|b| sprintf("%02x",b)}.join(":"),
          :signal   => parts[8],
          :free     => parts[9]
        }
      else
        false
      end
    end

    # Returns the firmware's protocol version and firmware version in a hash:
    #  {
    #    :protocol => "1.124",
    #    :firmware => "1.3"
    #  }
    def get_firmware_version
      result = send_and_receive(@@op_codes["get_firmware_version"], [])
      if result
        result = result.join.from_hex_str
        {
          :protocol => "#{result[1]}.#{result[0]}",
          :firmware => "#{result[3]}.#{result[2]}"
        }
      else
        false
      end
    end

    # Returns the battery voltage in millivolts.
    def get_battery_level
      result = send_and_receive(@@op_codes["get_battery_level"], [])
      result == false ? false : result.join.from_hex_str.unpack("v")[0]
    end

    # Set the name of the nxt.  Max length 15 characters.
    def set_brick_name(name="NXT")
      raise "name too large" if name.size > 15

      result = send_and_receive(@@op_codes["set_brick_name"], name.bytes.to_a)
      result = true if result == ""
      result
    end

  end
end
