module NXT
  class NXT

    # Get the status of an LS port (like ultrasonic sensor).  Returns the count of available bytes to read.
    # * <tt>port</tt> - input port (SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4)
    def ls_get_status(port)
      cmd = [port]
      result = send_and_receive @@op_codes["ls_get_status"], cmd
      result[0]
    end

    # Write data to lowspeed I2C port (for talking to the ultrasonic sensor)
    # * <tt>port</tt> - input port (SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4)
    # * <tt>i2c_msg</tt> - the I2C message to send to the lowspeed controller; the first byte
    #   specifies the transmitted data length, the second byte specifies the expected respone
    #   data length, and the remaining 16 bytes are the transmitted data. See UltrasonicComm
    #   for an example of an I2C sensor protocol implementation.
    #
    #   For LS communication on the NXT, data lengths are limited to 16 bytes per command.  Rx data length
    #   MUST be specified in the write command since reading from the device is done on a master-slave basis
    def ls_write(port,i2c_msg)
      cmd = [port] + i2c_msg
      result = send_and_receive @@op_codes["ls_write"], cmd
      result = true if result == ""
      result
    end

    # Read data from from lowspeed I2C port (for receiving data from the ultrasonic sensor)
    # * <tt>port</tt> - input port (SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4)
    # Returns a hash containing:
    #   {
    #     :bytes_read => number of bytes read
    #     :data       => Rx data (padded)
    #   }
    #
    #   For LS communication on the NXT, data lengths are limited to 16 bytes per command.
    #   Furthermore, this protocol does not support variable-length return packages, so the response
    #   will always contain 16 data bytes, with invalid data bytes padded with zeroes.
    def ls_read(port)
      cmd = [port]
      result = send_and_receive @@op_codes["ls_read"], cmd
      if result
        result = result.from_hex_str
        {
          :bytes_read => result[0],
          :data       => result[1..-1]
        }
      else
        false
      end
    end

  end
end
