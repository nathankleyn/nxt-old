# NXT

Control a Lego NXT 2.0 brick using Ruby code. This library works by piping
commands over a serial connection to the brick, allowing you to write Ruby
scripts to control your bot. This means you can use both the Bluetooth and USB
serial ports provided on the brick as interfaces within your code.

This project used to be based on "ruby-nxt", and Tony Buser's subsequent rewrite
"nxt". It is now a complete rewrite, based heavily in some parts on the
aforesaid projects internally, but with a brand new external API that should
prove cleaner and easier to work with.

This code implements direct command, as outlined in "Appendix 2-LEGO MINDSTORMS
NXT Direct Commands.pdf".

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
* Try to use deviceless Bluetooth testing, will simulate responses using
  mocks/stubs wherever possible. I'm aiming to have the entire framework
  testable without a NXT brick.
* Package it up as a gem called "nxt" to replace the original "ruby-nxt" package.
* Wrap all modules in a NXT namespace.
* Move interfaces into a seperate module for each type, ie. SerialPort and USB.
