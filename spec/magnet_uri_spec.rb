require 'spec_helper'

describe Nanny::MagnetURI do

  it "takes an URI" do
    Nanny::MagnetURI.new('foo').uri.should == 'foo'
  end

  describe "#hash" do
    it "parses the hash from the URI" do
      uri = Nanny::MagnetURI.new('magnet:?xt=urn:btih:f6c598d155e53f793d429582afaa160f2101b3fb&dn=The+Office+US+-+The+Complete+Season+8+HDTV&tr=udp%3A%2F%2Ftracker.1337x.org%3A80%2Fannounce&tr=http%3A%2F%2Ftracker.publicbt.com%2Fannounce&tr=http%3A%2F%2Fexodus.desync.com%2Fannounce')
      uri.hash.should == 'f6c598d155e53f793d429582afaa160f2101b3fb'
    end
  end

end

