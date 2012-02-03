module NXT
  module Mixins
    module InputOutput
      include Mixins::Consts

      # Set various parameters for the output motor port(s).
      # * <tt>port</tt> - output port (MOTOR_A, MOTOR_B, MOTOR_C, or MOTOR_ALL)
      # * <tt>power</tt> - power set point (-100 - 100)
      # * <tt>mode</tt> - output mode (MOTORON, BRAKE, REGULATED)
      # * <tt>reg_mode</tt> - regulation mode (REGULATION_MODE_IDLE, REGULATION_MODE_MOTOR_SPEED, REGULATION_MODE_MOTOR_SYNC)
      # * <tt>turn_ratio</tt> - turn ratio (-100 - 100) negative shifts power to left motor, positive to right, 50 = one stops, other moves, 100 = each motor moves in opposite directions
      # * <tt>run_state</tt> - run state (MOTOR_RUN_STATE_IDLE, MOTOR_RUN_STATE_RAMPUP, MOTOR_RUN_STATE_RUNNING, MOTOR_RUN_STATE_RAMPDOWN)
      # * <tt>tacho_limit</tt> - tacho limit (number, 0 - run forever)
      def set_output_state(port,power,mode,reg_mode,turn_ratio,run_state,tacho_limit)
        cmd = [port,power,mode,reg_mode,turn_ratio,run_state] + [tacho_limit].pack("V").unpack("C4")
        result = send_and_receive @@op_codes["set_output_state"], cmd
        result = true if result == ""
        result
      end

      # Set various parameters for an input sensor port.
      # * <tt>port</tt> - input port (SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4)
      # * <tt>type</tt> - sensor type (NO_SENSOR, SWITCH, TEMPERATURE, REFLECTION, ANGLE, LIGHT_ACTIVE, LIGHT_INACTIVE, SOUND_DB, SOUND_DBA, CUSTOM, LOWSPEED, LOWSPEED_9V, NO_OF_SENSOR_TYPES)
      # * <tt>mode</tt> - sensor mode (RAWMODE, BOOLEANMODE, TRANSITIONCNTMODE, PERIODCOUNTERMODE, PCTFULLSCALEMODE, CELSIUSMODE, FAHRENHEITMODE, ANGLESTEPMODE, SLOPEMASK, MODEMASK)
      def set_input_mode(port,type,mode)
        cmd = [port,type,mode]
        result = send_and_receive @@op_codes["set_input_mode"], cmd
        result = true if result == ""
        result
      end

      # Get the state of the output motor port.
      # * <tt>port</tt> - output port (MOTOR_A, MOTOR_B, MOTOR_C)
      # Returns a hash with the following info (enumerated values see: set_output_state):
      #   {
      #     :port               => see: output ports,
      #     :power              => -100 - 100,
      #     :mode               => see: output modes,
      #     :reg_mode           => see: regulation modes,
      #     :turn_ratio         => -100 - 100 negative shifts power to left motor, positive to right, 50 = one stops, other moves, 100 = each motor moves in opposite directions,
      #     :run_state          => see: run states,
      #     :tacho_limit        => current limit on a movement in progress, if any,
      #     :tacho_count        => internal count, number of counts since last reset of the motor counter,
      #     :block_tacho_count  => current position relative to last programmed movement,
      #     :rotation_count     => current position relative to last reset of the rotation sensor for this motor
      #   }
      def get_output_state(port)
        cmd = [port]
        result = send_and_receive @@op_codes["get_output_state"], cmd

        if result
          result_parts = result.join.from_hex_str.unpack('C6V4')
          (7..9).each do |i|
            result_parts[i] = result_parts[i].as_signed if result_parts[i].kind_of? Bignum
          end

          {
            :port               => result_parts[0],
            :power              => result_parts[1],
            :mode               => result_parts[2],
            :reg_mode           => result_parts[3],
            :turn_ratio         => result_parts[4],
            :run_state          => result_parts[5],
            :tacho_limit        => result_parts[6],
            :tacho_count        => result_parts[7],
            :block_tacho_count  => result_parts[8],
            :rotation_count     => result_parts[9]
          }
        else
          false
        end
      end

      # Get the current values from an input sensor port.
      # * <tt>port</tt> - input port (SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4)
      # Returns a hash with the following info (enumerated values see: set_input_mode):
      #   {
      #     :port             => see: input ports,
      #     :valid            => boolean, true if new data value should be seen as valid data,
      #     :calibrated       => boolean, true if calibration file found and used for 'Calibrated Value' field below,
      #     :type             => see: sensor types,
      #     :mode             => see: sensor modes,
      #     :value_raw        => raw A/D value (device dependent),
      #     :value_normal     => normalized A/D value (0 - 1023),
      #     :value_scaled     => scaled value (mode dependent),
      #     :value_calibrated => calibrated value, scaled to calibration (TODO: CURRENTLY UNUSED)
      #   }
      def get_input_values(port)
        cmd = [port]
        result = send_and_receive @@op_codes["get_input_values"], cmd

        if result
          result_parts = result.join.from_hex_str.unpack('C5v4')
          result_parts[1] == 0x01 ? result_parts[1] = true : result_parts[1] = false
          result_parts[2] == 0x01 ? result_parts[2] = true : result_parts[2] = false

          (7..8).each do |i|
            # convert to signed word
            # FIXME: is this right?
            result_parts[i] = -1*(result_parts[i]^0xffff) if result_parts[i] > 0xfff
          end

          {
            :port             => result_parts[0],
            :valid            => result_parts[1],
            :calibrated       => result_parts[2],
            :type             => result_parts[3],
            :mode             => result_parts[4],
            :value_raw        => result_parts[5],
            :value_normal     => result_parts[6],
            :value_scaled     => result_parts[7],
            :value_calibrated => result_parts[8],
          }
        else
          false
        end
      end

      # Reset the scaled value on an input sensor port.
      # * <tt>port</tt> - input port (SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4)
      def reset_input_scaled_value(port)
        cmd = [port]
        result = send_and_receive @@op_codes["reset_input_scaled_value"], cmd
        result = true if result == ""
        result
      end

      # Reset the position of an output motor port.
      # * <tt>port</tt> - output port (MOTOR_A, MOTOR_B, MOTOR_C)
      # * <tt>relative</tt> - boolean, true - position relative to last movement, false - absolute position
      def reset_motor_position(port,relative = false)
        cmd = []
        cmd << port
        relative ? cmd << 0x01 : cmd << 0x00
        result = send_and_receive @@op_codes["reset_motor_position"], cmd
        result = true if result == ""
        result
      end

    end
  end
end
