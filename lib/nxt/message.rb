module NXT
  class NXT

    # Write a message to a specific inbox on the NXT.  This is used to send a message to a currently running program.
    # * <tt>inbox</tt> - inbox number (1 - 10)
    # * <tt>message</tt> - message data
    def message_write(inbox,message)
      cmd = []
      cmd << inbox - 1
      case message.class.to_s
        when "String"
          cmd << message.size + 1
          message.each_byte do |b|
            cmd << b
          end
        when "Fixnum"
          cmd << 5 # msg size + 1
          #cmd.concat([(message & 255),(message >> 8),(message >> 16),(message >> 24)])
          [message].pack("V").each_byte{|b| cmd << b}
        when "TrueClass"
          cmd << 2 # msg size + 1
          cmd << 1
        when "FalseClass"
          cmd << 2 # msg size + 1
          cmd << 0
        else
          raise "Invalid message type"
      end
      result = send_and_receive @@op_codes["message_write"], cmd
      result = true if result == ""
      result
    end

    # Read a message from a specific inbox on the NXT.
    # * <tt>inbox_remote</tt> - remote inbox number (1 - 10)
    # * <tt>inbox_local</tt> - local inbox number (1 - 10) (not sure why you need this?)
    # * <tt>remove</tt> - boolean, true - clears message from remote inbox
    def message_read(inbox_remote,inbox_local = 1,remove = false)
      cmd = [inbox_remote, inbox_local]
      remove ? cmd << 0x01 : cmd << 0x00
      result = send_and_receive @@op_codes["message_read"], cmd
      result == false ? false : result[2..-1].from_hex_str.unpack("A*")[0]
    end

  end
end
