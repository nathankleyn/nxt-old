require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Array do
  describe "#to_hex_str"
    it "should convert each item in an Array to hex string format" do
      [1, 2, 3, 4, 5].to_hex_str.should eq(["0x01 ", "0x02 ", "0x03 ", "0x04 ", "0x05 "])
    end
end

describe Bignum do
  describe "#as_signed" do
    it "should convert an unsigned bignum to a signed bignum" do
      10000000000000000000.as_signed.should eq(-9999999999667601407)
    end

    it "should return nil when passed a signed number" do
      -9999999999667601407.as_signed.should be_nil
    end
  end
end

describe String do
  describe "#to_hex_str" do
    it "should convert a string to hex characters" do
      "hello".to_hex_str.should eq("0x68 0x65 0x6c 0x6c 0x6f ")
    end
  end

  describe "#from_hex_str" do
    it "should convert from a hex char string to normal string" do
      "0x68 0x65 0x6c 0x6c 0x6f ".from_hex_str.should eq("hello")
    end
  end

  describe "#to_freq" do
    it "should convert a valid note to a frequency" do
      "a".to_freq.should eq(880)
    end

    it "should raise an error when given an invalid note" do
      expect do
        "w".to_freq
      end.to raise_error(StringToFreqError)
    end
  end
end
