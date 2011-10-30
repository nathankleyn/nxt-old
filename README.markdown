This is basically ruby-nxt. I'm simplifying things and moving it away from rubyforge.

Low-level interface for communicating directly with the NXT via a Bluetooth serial port or USB. Implements direct commands outlined in Appendix 2-LEGO MINDSTORMS NXT Direct Commands.pdf

Not all functionality is implemented yet!

For instructions on creating a bluetooth serial port connection:

* Linux: http://tonybuser.com/bluetooth-serial-port-to-nxt-in-linux
* Max OSX: http://tonybuser.com/bluetooth-serial-port-to-nxt-in-osx
* Windows: http://tonybuser.com/ruby-serialportnxt-on-windows

## Examples

First create a new NXT object and pass the device.

    @nxt = NXT.new("/dev/tty.NXT-DevB-1")

Rotate the motor connected to port B forwards indefinitely at 100% power:

    @nxt.set_output_state(
      NXT::MOTOR_B,
      100,
      NXT::MOTORON,
      NXT::REGULATION_MODE_MOTOR_SPEED,
      100,
      NXT::MOTOR_RUN_STATE_RUNNING,
      0
    )

Play a tone at 1000 Hz for 500 ms:

    @nxt.play_tone(1000,500)

Print out the current battery level:

    puts "Battery Level: #{@nxt.get_battery_level/1000.0} V"

## In-progress tasks

* Converting all of the old frameworkless tests to RSpec unit tests.
* Try to use deviceless Bluetooth testing, will simulate responses.
* Package it up as a gem called "nxt" to replace the original "ruby-nxt" package.
