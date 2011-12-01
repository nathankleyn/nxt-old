module NXT
  module Interface
    class SerialPort

      attr_accessor :dev

      def initialize(dev = nil)
        @dev = dev
      end

      def type
        "serialport"
      end

      def connect
        @connection = SerialPort.new(@dev, 57600, 8, 1, SerialPort::NONE)

        if !@connection.nil?
          @connection.flow_control = SerialPort::HARD
          @connection.read_timeout = 5000
        else
          raise "NXT::Interface::SerialPort#connect: Could not connect to #{dev}."
        end
      end

      def send(msg)
        msg = [(msg.size & 255), (msg.size >> 8)] + msg
        puts "Sending Message (size: #{msg.size}): #{msg.to_hex_str}" if $DEBUG
        msg.each do |b|
          @connection.putc b
        end
      end

      def receive
        len_header = @connection.sysread(2)
        msg = @connection.sysread(len_header.unpack("v")[0])
      end

      def close
        @connection.close if @connection && !@connection.closed?
      end

      def connected?
        !@connection.closed?
      end

    end

  end
end
