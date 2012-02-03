module NXT
  module Mixins
    module Sound
      include Mixins::Consts

      # Play a sound file stored on the NXT.
      # * <tt>name</tt> - file name of the sound file to play
      # * <tt>repeat</tt> - Loop? (true or false)
      def play_sound_file(name,repeat = false)
        cmd = []
        repeat ? cmd << 0x01 : cmd << 0x00
        name.each_byte do |b|
          cmd << b
        end
        result = send_and_receive @@op_codes["play_sound_file"], cmd
        result = true if result == ""
        result
      end

      # Play a tone.
      # * <tt>freq</tt> - frequency for the tone in Hz
      # * <tt>dur</tt> - duration for the tone in ms
      def play_tone(freq,dur,request_reply=true)
        cmd = [(freq & 255),(freq >> 8),(dur & 255),(dur >> 8)]
        result = send_and_receive @@op_codes["play_tone"], cmd, request_reply
        result = true if result == ""
        result
      end

      # Stop any currently playing sounds.
      def stop_sound_playback
        cmd = []
        result = send_and_receive @@op_codes["stop_sound_playback"], cmd
        result = true if result == ""
        result
      end

    end
  end
end
