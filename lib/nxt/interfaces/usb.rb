module NXT
  module Interface
    class USB

      USB_ID_VENDOR_LEGO = 0x0694
      USB_ID_PRODUCT_NXT = 0x0002
      USB_OUT_ENDPOINT   = 0x01
      USB_IN_ENDPOINT    = 0x82
      USB_TIMEOUT        = 1000
      USB_READSIZE       = 64
      USB_INTERFACE      = 0

      attr_accessor :interface

      def initialize(interface = nil)
        @interface = interface || $INTERFACE || USB_INTERFACE
      end

      def type
        "usb"
      end

      def connect
        # Search through all USB devices, check if there is one that matches
        # the specifications of the NXT brick.
        #
        # TODO: Find a better way to do this.
        ::USB.devices.find_all do |device|
          @device = device if device.idVendor == USB_ID_VENDOR_LEGO && device.idProduct == USB_ID_PRODUCT_NXT
        end

        raise "NXT::Interface::USB#connect: Cannot find USB device." if @device.nil?

        @connection = @device.open
        @connection.usb_reset
        @connection.claim_interface(@interface)
      end

      def send(msg)
        puts "Sending Message (size: #{msg.size}): #{msg.to_hex_str}" if $DEBUG
        @connection.usb_bulk_write(USB_OUT_ENDPOINT, msg.pack("C*"), USB_TIMEOUT)
      end

      def receive
        msg = ""

        # ruby-usb is a little odd with usb_bulk_read, instead of passing a read size, you pass a string
        # that is of the size you want to read...
        USB_READSIZE.times do
          msg << " "
        end

        len_header = @connection.usb_bulk_read(USB_IN_ENDPOINT, msg, USB_TIMEOUT)
        msg = msg[0..(len_header - 1)].to_s
        len_header = len_header.to_s

        msg
      end

      def close
        if @connection
          @connection.release_interface(@interface)
          @connection.usb_close
        end
      end

      def connected?
        !@connection.revoked?
      end

    end

  end
end
