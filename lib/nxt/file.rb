module NXT
  module Mixins
    module File
      include Mixins::Consts

      # Closes an open file handle.  Returns the handle number on success.
      def close_handle(handle)
        cmd = [handle]
        result = send_and_receive @@op_codes["close_handle"], cmd
        result ? result.join.from_hex_str.unpack("C")[0] : false
      end

      # Find a file in flash memory.  The following wildcards are allowed:
      # * [filename].[extension]
      # * *.[file type name]
      # * [filename].*
      # * *.*
      # In other words, you can't do partial name searches...
      #
      # Returns a hash with the following info:
      #  {
      #    :handle  => handle number used with other read/write commands,
      #    :name    => name of the file found,
      #    :size    => size of the file in bytes
      #  }
      #
      # This command creates a file handle within the nxt, so remember to use
      # close_handle command to release it.  Handle will automatically be released
      # if it encounters an error.
      def find_first(name="*.*")
        raise "NXT#find_first: Given file name is too large." if name.size > 19

        result = send_and_receive(@@op_codes["find_first"], name.bytes.to_a)

        if result
          parts = result.join.from_hex_str.unpack("CZ19V")

          # TODO: Convert to OpenStruct or something.
          {
            :handle => parts[0],
            :name   => parts[1],
            :size   => parts[2]
          }

        else
          # TODO: Can we raise something meaningful here?
          false
        end
      end

      # Find the next file from a previously found file handle like from the
      # find_first command.
      #
      # Returns a hash with the following info:
      #  {
      #    :handle  => handle number used with other read/write commands,
      #    :name    => name of the file found,
      #    :size    => size of the file in bytes
      #  }
      #
      # The handle passed will change to the next file found, don't forget to
      # release the handle with close_handle command.  When it runs out of files, it
      # will return false and handle will be released.
      def find_next(handle)
        result = send_and_receive(@@op_codes["find_next"], [handle])

        if result
          parts = result.join.from_hex_str.unpack("CZ19V")

          # TODO: Convert to OpenStruct or something.
          {
            :handle => parts[0],
            :name   => parts[1],
            :size   => parts[2]
          }

        else
          # TODO: Can we raise something meaningful here?
          false
        end
      end

      # Open a file to read from.
      #
      # Returns a has with the following info:
      #  {
      #    :handle => handle number used with read command,
      #    :size   => size of the file in bytes (FIXME: size returned doesn't appear to be correct?)
      #  }
      #
      # This command creates a file handle within the nxt, so remember to use
      # close_handle command to release it.  Handle will automatically be released
      # if it encounters an error.
      def open_read(name)
        raise "name too large" if name.size > 19

        result = send_and_receive(@@op_codes["open_read"], name.bytes.to_a)

        if result
          parts = result.join.from_hex_str.unpack("CV")

          {
            :handle => parts[0],
            :size   => parts[1]
          }

        else
          # TODO: Can we raise something meaningful here?
          false
        end
      end

      # Open and return a write handle number for creating a new file with
      # the write command.  You must specify the filename and the desired
      # size of the file in bytes.
      #
      # This command creates a file handle within the nxt, so remember to use
      # close_handle command to release it.  Handle will automatically be released
      # if it encounters an error.
      def open_write(name,size=100)
        raise "name too large" if name.size > 19

        # TODO: Comment this once we work out what it does.
        cmd = name.ljust(19).bytes.map do |b|
          (b == 0x20 ? 0x00 : b)
        end

        [size].pack("V").each_byte do |b|
          cmd << b
        end

        result = send_and_receive(@@op_codes["open_write"], cmd)

        (result ? result.join.from_hex_str.unpack("C")[0] : false)
      end

      # Write data to a handle created with the open_write command.
      #
      # Returns a hash containing:
      #  {
      #    :handle => the handle you're working with,
      #    :size   => the size in bytes of the data that has been written to flash
      #  }
      #
      # FIXME: I can't seem to get this to work, it always gives an error saying
      # "End of file expected"
      def write_file(handle,data="")
        cmd = [handle]
        data.to_s.each_byte { |b| cmd << b }
        result = send_and_receive(@@op_codes["write_file"], cmd)
        if result
          parts = result.join.from_hex_str.unpack("Cv")
          {
            :handle => parts[0],
            :size   => parts[1]
          }
        else
          false
        end
      end

      # Reads a file from an open read handle from the open_read command.
      #
      # Returns a hash containing:
      #  {
      #    :handle => the handle that you're working with,
      #    :size   => number of bytes that have been read,
      #    :data   => the data that was read
      #  }
      #
      # FIXME: only works with small sizes, there seems to be a bug in the way
      # sysread is working with ruby serialport...
      def read_file(handle,size=100)
        cmd = [handle]
        [size].pack("v").each_byte { |b| cmd << b }
        result = send_and_receive @@op_codes["read_file"], cmd
        if result
          data = result.from_hex_str
          {
            :handle => data[0],
            :size   => data[1..2].unpack("v")[0],
            :data   => data[3..-1]
          }
        else
          false
        end
      end

      # Deletes a file.  Returns the name of the file deleted.
      def delete_file(name)
        cmd = []
        name.each_byte { |b| cmd << b }
        result = send_and_receive @@op_codes["delete_file"], cmd
        result ? result.join.from_hex_str.unpack("Z19")[0] : false
      end

    end
  end
end
