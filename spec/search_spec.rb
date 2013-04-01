require 'spec_helper'

describe Nanny::Search do

  describe "#search_torrents" do
    it "transforms each feed item into a torrent" do
      doc = double('Nokogiri::XML')
      doc.stub(:xpath).with(Nanny::Search::FEED_ITEMS_XPATH).and_return [ 'feed_item' ]
      subject.stub(:document_for_query).with('my query').and_return doc
      subject.stub(:torrent_from_item).with('feed_item').and_return 'torrent'
      torrents = subject.search_torrents('my query')
      torrents.should == [ 'torrent' ]
    end
  end

  describe "#torrent_from_item" do
    it "parses feed item into torrent" do
      item_xml = dump_file('item.xml').read
      torrent = subject.torrent_from_item Nokogiri::XML(item_xml)

      torrent.should be_a Nanny::Torrent
      torrent.title.should == 'The Office US S09E12 HDTV x264 LOL'
      torrent.url.should == 'http://torrentz.eu/419b8bf295303d977c97c07b8bd63349c181776e'
      torrent.size.should == 170917888
      torrent.seeds.should == 12
      torrent.peers.should == 1
      torrent.hash.should == '419b8bf295303d977c97c07b8bd63349c181776e'
    end
  end

  example do
    VCR.use_cassette "search_torrents" do
      torrents = subject.search_torrents "The Office Season 8"
      torrents.should have(3).torrents
      torrents.first.title.should == "The Office US The Complete Season 8 HDTV"
    end
  end

  example do
    VCR.use_cassette "complete integration" do
      torrents = subject.search_torrents "The Office Season 8"
      torrents.first.torrent_url.should == 'http://torcache.net/torrent/F6C598D155E53F793D429582AFAA160F2101B3FB.torrent'
    end
  end

end

