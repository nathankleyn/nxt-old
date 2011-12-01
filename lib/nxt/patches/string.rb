require 'pry'

class StringToFreqError < StandardError; end

class String
  def to_hex_str
    str = ""
    self.each_byte {|b| str << '0x%02x ' % b}
    str
  end

  def from_hex_str
    data = self.split(' ')
    str = ""
    data.each{|h| eval "str += '%c' % #{h}"}
    str
  end

  # converts a note string to equiv frequency in Hz
  # TODO need to get a better range...
  # TODO: This feels iffy patching String to get a very specific method;
  #       I think this would be better in the Sound command class - NK.
  def to_freq
    case self.downcase
      when "c"
        523
      when "c#"
        554
      when "d"
        587
      when "d#"
        622
      when "e"
        659
      when "f"
        698
      when "f#"
        740
      when "g"
        784
      when "g#"
        830
      when "a"
        880
      when "a#"
        923
      when "b"
        988
      else
        raise StringToFreqError.new("Cannot convert the string #{self} to a frequency, unknown note.")
    end
  end
end
