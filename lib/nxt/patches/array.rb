class Array
  def to_hex_str
    self.collect do |e|
      "0x%02x " % e
    end
  end
end
