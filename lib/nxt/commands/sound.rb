# Control Mindstorms NXT via Bluetooth or USB
# Copyright (C) 2006-2009 Tony Buser <tbuser@gmail.com> - http://tonybuser.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# Implements the "Sound" block in NXT-G
class Commands::Sound

  attr_accessor :action
  attr_accessor :control
  attr_accessor :volume # TODO not sure how to set this with direct commands?
                        # TODO: Pretty sure you can't do this with DC's - NK
  attr_accessor :repeat
  attr_accessor :file
  attr_accessor :note
  attr_accessor :duration
  attr_accessor :wait

  def initialize(nxt)
    @nxt      = nxt

    # defaults the same as NXT-G
    @action   = :file
    @control  = :play
    @volume   = 75
    @repeat   = false
    @file     = "Good Job.rso"
    @note     = "C"
    @duration = 0.5
    @wait     = true
  end

  # execute the Sound command based on the properties specified
  def start
    if @action == :file
      @nxt.play_sound_file(@file,@repeat)
    else
      @nxt.play_tone(@note.to_freq,(@duration * 1000).to_i)
    end

    # TODO figure out a logical way to repeat a tone without blocking execution
    # TODO: I would like to implement evented commands, where we use queues - NK.
    if @wait
      if @action == :tone
        sleep(@duration)
      else
        # TODO don't know how to sleep until a sound file finishes
      end
    end
  end

  # stop the Sound command
  def stop
    @nxt.stop_sound_playback
  end

end
