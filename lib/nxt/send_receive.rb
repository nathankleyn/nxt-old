module NXT
  class NXT

    # Send message and return response
    def send_and_receive(op,cmd,request_reply=true)
      case op[0]
      when "direct"
        request_reply ? command_byte = [0x00] : command_byte = [0x80]
      when "system"
        request_reply ? command_byte = [0x01] : command_byte = [0x81]
      end

      msg = command_byte + [op[1]] + cmd + [0x00]

      send_cmd(msg)

      if request_reply
        ok,response = recv_reply

        if ok and response[1] == op[1]
          data = response[3..response.size]
          # TODO ? if data contains a \n character, ruby seems to pass the parts before and after the \n
          # as two different parameters... we need to encode the data into a format that doesn't
          # contain any \n's and then decode it in the receiving method
          data = data.to_hex_str
        elsif !ok
          $stderr.puts response
          data = false
        else
          $stderr.puts "ERROR: Unexpected response #{response}"
          data = false
        end
      else
        data = true
      end
      data
    end

    # Send direct command bytes
    def send_cmd(msg)
      @@mutex.synchronize do
        @connection.send(msg)
      end
    end

    # Process the reply
    def recv_reply
      @@mutex.synchronize do

        begin
          msg = @connection.receive
        rescue
          raise "Cannot read from the NXT. Make sure the device is on and connected."
        end

        puts "Received Message: #{len_header.to_hex_str}#{msg.join}" if $DEBUG

        # This is a necessary evil, because of Ruby 1.9 and its encoding.
        #
        # In Ruby 1.9, here, msg[0] is equal to something like:
        #
        #   \x02
        #
        # In Ruby 1.8, msg[0] is equal to something like:
        #
        #   2
        #
        # Seemingly, converting to a byte array gives us the same value on both
        # sides of the Ruby spectrum.
        #
        # TODO: Does this need to happen on both USB and Serialport?
        # I've only tested this on Serialport, and there's no unit test for
        # this yet.
        msg = msg.bytes.to_a

        # The first byte must be equal to a reply telegram, otherwise we
        # check for command specific error codes in byte two.
        raise "NXT#recv_reply: Returned something other then a reply telegram" if msg[0] != 0x02
        raise "NXT#recv_reply: #{@@error_op_codes[msg[2]]}" if msg[2] != 0x00

        return [true, msg]

      end
    end

  end
end
