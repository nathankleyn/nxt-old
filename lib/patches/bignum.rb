class Bignum
  # This is needed because String#unpack() can't handle little-endian signed longs...
  # instead we unpack() as a little-endian unsigned long (i.e. 'V') and then use this
  # method to convert to signed long.
  def as_signed
    -1*(self^0xffffffff) if self > 0xfffffff
  end
end
