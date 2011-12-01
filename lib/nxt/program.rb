module NXT
  class NXT

    # Start a program stored on the NXT.
    # * <tt>name</tt> - file name of the program
    def start_program(name)
      cmd = []
      name.each_byte do |b|
        cmd << b
      end
      result = send_and_receive @@op_codes["start_program"], cmd
      result = true if result == ""
      result
    end

    # Stop any programs currently running on the NXT.
    def stop_program
      cmd = []
      result = send_and_receive @@op_codes["stop_program"], cmd
      result = true if result == ""
      result
    end

    # Returns the name of the program currently running on the NXT.
    # Returns an error If no program is running.
    def get_current_program_name
      cmd = []
      result = send_and_receive @@op_codes["get_current_program_name"], cmd
      result == false ? false : result.join.from_hex_str.unpack("A*")[0]
    end

  end
end
