# encoding: utf-8

require 'spec_helper'

describe Nanny::Tracker do

  describe "#valid_url?" do
    subject { Nanny::Tracker.new('http://google.it/foobar').valid_url?(url) }

    context "torrent extension required" do
      let(:url) { "foobar.html" }
      it { should be_false }
    end

    context "valid URI required" do
      let(:url) { "fòòbar.html" }
      it { should be_false }
    end

    context "valid URI required" do
      let(:url) { "foobar.torrent" }
      it { should be_true }
    end
  end

  describe "#to_absolute_uri" do
    subject { Nanny::Tracker.new('http://google.it/foobar').to_absolute_url(url) }
    context "absolute URIs are left unchanged" do
      let(:url) { "http://foobar.com/foobar.html" }
      it { should == url }
    end
    context "relative URI become absolute based on tracker page" do
      let(:url) { "/bar.html" }
      it { should == 'http://google.it/bar.html' }
    end
    context "urls not starting with a forward slash are not handled correctly", fixme: true do
      let(:url) { "bar.html" }
      it { should == 'http://google.it/bar.html' }
    end
  end

  describe "#magnet_uri" do
    it "raises MagnetNotFound if cannot download the tracker page" do
      tracker = Nanny::Tracker.new('http://google.com')
      tracker.stub(:tracker_doc).and_raise Nanny::Tracker::PageNotAvailable
      lambda { tracker.magnet_uri }.should raise_error Nanny::Tracker::MagnetNotFound
    end

    example do
      VCR.use_cassette "fenopy" do
        tracker = Nanny::Tracker.new("http://fenopy.se/torrent/the+office+us+the+complete+season+8+hdtv/ODMxMzA4Mg")
        tracker.magnet_uri.hash.should == "f6c598d155e53f793d429582afaa160f2101b3fb"
      end
    end

    example do
      VCR.use_cassette "extratorrent" do
        tracker = Nanny::Tracker.new("http://extratorrent.com/torrent/2685289/The+Office+US+-+The+Complete+Season+8+HDTV.html")
        tracker.magnet_uri.hash.should == "f6c598d155e53f793d429582afaa160f2101b3fb"
      end
    end

    example do
      VCR.use_cassette "google" do
        tracker = Nanny::Tracker.new("http://google.com")
        lambda { tracker.magnet_uri }.should raise_error Nanny::Tracker::MagnetNotFound
      end
    end
  end

  describe "#torrent_url" do
    it "raises TorrentNotFound if cannot download the tracker page" do
      tracker = Nanny::Tracker.new('http://google.com')
      tracker.stub(:tracker_doc).and_raise Nanny::Tracker::PageNotAvailable
      lambda { tracker.torrent_url }.should raise_error Nanny::Tracker::TorrentNotFound
    end

    example do
      VCR.use_cassette "fenopy" do
        tracker = Nanny::Tracker.new("http://fenopy.se/torrent/the+office+us+the+complete+season+8+hdtv/ODMxMzA4Mg")
        tracker.torrent_url.should == "http://torcache.net/torrent/F6C598D155E53F793D429582AFAA160F2101B3FB.torrent"
      end
    end

    example do
      VCR.use_cassette "yourbittorrent" do
        tracker = Nanny::Tracker.new("http://yourbittorrent.com/torrent/3433946/the-lincoln-lawyer-italian-dvdrip-blw.html")
        tracker.torrent_url.should == "http://yourbittorrent.com/down/3433946.torrent"
      end
    end

    example do
      VCR.use_cassette "google" do
        tracker = Nanny::Tracker.new("http://google.com")
        lambda { tracker.torrent_url }.should raise_error Nanny::Tracker::TorrentNotFound
      end
    end
  end

  describe "#tracker_doc" do
    it "returns a Nokogiri HTML of tracker URL" do
      VCR.use_cassette "google" do
        tracker = Nanny::Tracker.new("http://google.com")
        tracker.tracker_doc.should be_a Nokogiri::HTML::Document
      end
    end
    it "gives up if download takes more than 2 seconds" do
      tracker = Nanny::Tracker.new("http://google.com")
      Nanny::HTTPClient.stub(:get).and_return {
        sleep 3
      }
      lambda { tracker.tracker_doc }.should raise_error Nanny::Tracker::PageNotAvailable
    end
  end

end
