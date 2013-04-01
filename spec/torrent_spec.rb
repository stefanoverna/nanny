require 'spec_helper'

describe Nanny::Torrent do

  describe "#human_size" do
    it "formats size" do
      Nanny::Torrent.new(size: 0).human_size.should == "0B"
      Nanny::Torrent.new(size: 5000).human_size.should == "4.9KB"
      Nanny::Torrent.new(size: 5000000).human_size.should == "4.8MB"
      Nanny::Torrent.new(size: 5000000000).human_size.should == "4.7GB"
    end
  end

  describe "#torrent_url" do
    it "returns Torcache URL" do
      torrent = Nanny::Torrent.new
      torrent.stub(:torcache_url).and_return('foo_url')
      torrent.torrent_url.should == 'foo_url'
    end
    it "returns torrent url from trackers otherwise" do
      torrent = Nanny::Torrent.new
      torrent.stub(:torcache_url).and_raise(Nanny::Torrent::URLNotFound)
      torrent.stub(:trackers_torrent_url).and_return('foo_url')
      torrent.torrent_url.should == 'foo_url'
    end
  end

  describe "#torcache_url" do
    it "uses hash" do
      Nanny::Torcache.stub(:url_for).with('foo').and_return('foo_url')
      Nanny::Torrent.new(hash: 'foo').torcache_url.should == 'foo_url'
    end
    it "else uses trackers magnet" do
      Nanny::Torcache.stub(:url_for).with('foo').and_raise(Nanny::Torcache::HashNotFound)
      torrent = Nanny::Torrent.new(hash: 'foo')
      torrent.stub(:trackers_torcache_url).and_return('bar_url')
      torrent.torcache_url.should == 'bar_url'
    end
  end

  describe "#trackers_torcache_url" do
    it "returns the Torcache URL for the first tracker with a magnet link" do
      failing_tracker = double('Tracker')
      failing_tracker.stub(:magnet_uri).and_raise(Nanny::Tracker::MagnetNotFound)

      tracker = double('Tracker')
      tracker.stub(:magnet_uri).and_return(stub(hash: 'XXX'))

      Nanny::Torcache.stub(:url_for).with('XXX').and_return('foo_url')

      subject.stub(:trackers).and_return [ failing_tracker, tracker ]
      subject.trackers_torcache_url.should == 'foo_url'
    end

    it "raises URLNotFound otherwise" do
      subject.stub(:trackers).and_return []
      lambda { subject.trackers_torcache_url }.should raise_error(Nanny::Torrent::URLNotFound)
    end
  end

  describe "#trackers_torrent_url" do
    it "returns the torrent URL for the first tracker" do
      failing_tracker = double('Tracker')
      failing_tracker.stub(:torrent_url).and_raise(Nanny::Tracker::TorrentNotFound)

      tracker = double('Tracker')
      tracker.stub(:torrent_url).and_return('foo_url')

      subject.stub(:trackers).and_return [ failing_tracker, tracker ]
      subject.trackers_torrent_url.should == 'foo_url'
    end

    it "raises URLNotFound otherwise" do
      subject.stub(:trackers).and_return []
      lambda { subject.trackers_torrent_url }.should raise_error(Nanny::Torrent::URLNotFound)
    end
  end

  describe "#trackers" do
    example do
      VCR.use_cassette "trackers" do
        torrent = Nanny::Torrent.new(url: 'http://torrentz.eu/f6c598d155e53f793d429582afaa160f2101b3fb')
        torrent.should have(8).trackers
      end
    end
  end

  example do
    VCR.use_cassette "complex_torrent_find" do
      torrent = Nanny::Torrent.new(hash: 'a47987c83f1a23d3ff328f89d1f8023f214297a8', url: 'http://torrentz.eu/a47987c83f1a23d3ff328f89d1f8023f214297a8')
      torrent.torrent_url.should == 'http://torrage.com/torrent/A47987C83F1A23D3FF328F89D1F8023F214297A8.torrent'
    end
  end

end
