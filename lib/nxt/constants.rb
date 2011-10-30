module Nxt
  module Mixins
    module Consts

      # usb const values
      USB_ID_VENDOR_LEGO = 0x0694
      USB_ID_PRODUCT_NXT = 0x0002
      USB_OUT_ENDPOINT   = 0x01
      USB_IN_ENDPOINT    = 0x82
      USB_TIMEOUT        = 1000
      USB_READSIZE       = 64
      USB_INTERFACE      = 0

      # sensors
      SENSOR_1  = 0x00
      SENSOR_2  = 0x01
      SENSOR_3  = 0x02
      SENSOR_4  = 0x03

      # motors
      MOTOR_A   = 0x00
      MOTOR_B   = 0x01
      MOTOR_C   = 0x02
      MOTOR_ALL = 0xFF

      # output mode
      COAST     = 0x00 # motor will rotate freely?
      MOTORON   = 0x01 # enables PWM power according to speed
      BRAKE     = 0x02 # voltage is not allowed to float between PWM pulses, improves accuracy, uses more power
      REGULATED = 0x04 # required in conjunction with output regulation mode setting

      # output regulation mode
      REGULATION_MODE_IDLE        = 0x00 # disables regulation
      REGULATION_MODE_MOTOR_SPEED = 0x01 # auto adjust PWM duty cycle if motor is affected by physical load
      REGULATION_MODE_MOTOR_SYNC  = 0x02 # attempt to keep rotation in sync with another motor that has this set, also involves turn ratio

      # output run state
      MOTOR_RUN_STATE_IDLE        = 0x00 # disables power to motor
      MOTOR_RUN_STATE_RAMPUP      = 0x10 # ramping to a new SPEED set-point that is greater than the current SPEED set-point
      MOTOR_RUN_STATE_RUNNING     = 0x20 # enables power to motor
      MOTOR_RUN_STATE_RAMPDOWN    = 0x40 # ramping to a new SPEED set-point that is less than the current SPEED set-point

      # sensor type
      NO_SENSOR           = 0x00
      SWITCH              = 0x01
      TEMPERATURE         = 0x02
      REFLECTION          = 0x03
      ANGLE               = 0x04
      LIGHT_ACTIVE        = 0x05
      LIGHT_INACTIVE      = 0x06
      SOUND_DB            = 0x07
      SOUND_DBA           = 0x08
      CUSTOM              = 0x09
      LOWSPEED            = 0x0A
      LOWSPEED_9V         = 0x0B
      NO_OF_SENSOR_TYPES  = 0x0C

      # sensor mode
      RAWMODE             = 0x00 # report scaled value equal to raw value
      BOOLEANMODE         = 0x20 # report scaled value as 1 true or 0 false, false if raw value > 55% of total range, true if < 45%
      TRANSITIONCNTMODE   = 0x40 # report scaled value as number of transitions between true and false
      PERIODCOUNTERMODE   = 0x60 # report scaled value as number of transitions from false to true, then back to false
      PCTFULLSCALEMODE    = 0x80 # report scaled value as % of full scale reading for configured sensor type
      CELSIUSMODE         = 0xA0
      FAHRENHEITMODE      = 0xC0
      ANGLESTEPSMODE      = 0xE0 # report scaled value as count of ticks on RCX-style rotation sensor
      SLOPEMASK           = 0x1F
      MODEMASK            = 0xE0

      @@op_codes = {
        # Direct Commands
        'start_program'             => ["direct",0x00],
        'stop_program'              => ["direct",0x01],
        'play_sound_file'           => ["direct",0x02],
        'play_tone'                 => ["direct",0x03],
        'set_output_state'          => ["direct",0x04],
        'set_input_mode'            => ["direct",0x05],
        'get_output_state'          => ["direct",0x06],
        'get_input_values'          => ["direct",0x07],
        'reset_input_scaled_value'  => ["direct",0x08],
        'message_write'             => ["direct",0x09],
        'reset_motor_position'      => ["direct",0x0A],
        'get_battery_level'         => ["direct",0x0B],
        'stop_sound_playback'       => ["direct",0x0C],
        'keep_alive'                => ["direct",0x0D],
        'ls_get_status'             => ["direct",0x0E],
        'ls_write'                  => ["direct",0x0F],
        'ls_read'                   => ["direct",0x10],
        'get_current_program_name'  => ["direct",0x11],
        'message_read'              => ["direct",0x13],
        # System Commands
        'open_read'                 => ["system",0x80],
        'open_write'                => ["system",0x81],
        'read_file'                 => ["system",0x82],
        'write_file'                => ["system",0x83],
        'close_handle'              => ["system",0x84],
        'delete_file'               => ["system",0x85],
        'find_first'                => ["system",0x86],
        'find_next'                 => ["system",0x87],
        'get_firmware_version'      => ["system",0x88],
        'open_write_linear'         => ["system",0x89],
        'open_read_linear'          => ["system",0x8A], # internal command?
        'open_write_data'           => ["system",0x8B],
        'open_append_data'          => ["system",0x8C],
        'boot'                      => ["system",0x97], # USB only...
        'set_brick_name'            => ["system",0x98],
        'get_device_info'           => ["system",0x9B],
        'delete_user_flash'         => ["system",0xA0],
        'poll_command_length'       => ["system",0xA1],
        'poll_command'              => ["system",0xA2],
        'bluetooth_factory_reset'   => ["system",0xA4], # cannot be transmitted via bluetooth
        # IO-Map Access
        'request_first_module'      => ["system",0x90],
        'request_next_module'       => ["system",0x91],
        'close_module_handle'       => ["system",0x92],
        'read_io_map'               => ["system",0x94],
        'write_io_map'              => ["system",0x95]
      }

      @@error_codes = {
        # Direct Commands
        0x20 => "Pending communication transaction in progress",
        0x40 => "Specified mailbox queue is empty",
        0xBD => "Request failed (i.e. specified file not found)",
        0xBE => "Unknown command opcode",
        0xBF => "Insane packet",
        0xC0 => "Data contains out-of-range values",
        0xDD => "Communication bus error",
        0xDE => "No free memory in communication buffer",
        0xDF => "Specified channel/connection is not valid",
        0xE0 => "Specified channel/connection not configured or busy",
        0xEC => "No active program",
        0xED => "Illegal size specified",
        0xEE => "Illegal mailbox queue ID specified",
        0xEF => "Attempted to access invalid field of a structure",
        0xF0 => "Bad input or output specified",
        0xFB => "Insufficient memory available",
        0xFF => "Bad arguments",
        # System Commands
        0x81 => "No more handles",
        0x82 => "No space",
        0x83 => "No more files",
        0x84 => "End of file expected",
        0x85 => "End of file",
        0x86 => "Not a linear file",
        0x87 => "File not found",
        0x88 => "Handle all ready closed",
        0x89 => "No linear space",
        0x8A => "Undefined error",
        0x8B => "File is busy",
        0x8C => "No write buffers",
        0x8D => "Append not possible",
        0x8E => "File is full",
        0x8F => "File exists",
        0x90 => "Module not found",
        0x91 => "Out of boundry",
        0x92 => "Illegal file name",
        0x93 => "Illegal handle"
      }

    end
  end
end
