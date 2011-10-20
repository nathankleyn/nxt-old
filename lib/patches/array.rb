class Array
  def to_hex_str
    self.collect{|e| "0x%02x " % e}
  end
end
