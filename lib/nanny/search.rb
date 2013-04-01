require 'nokogiri'
require 'addressable/template'

module Nanny
  class Search

    SIZE_UNITS = %w(b kb mb gb tb)
    FEED_ITEMS_XPATH = '//rss/channel/item'
    FEED_TEMPLATE_URL = Addressable::Template.new("http://torrentz.eu/feed?q={query}")
    FEED_DESC_REGEXP = /
      Size: \s* (?<size>\d+) \s* (?<size_unit>[KMGT]?B)
      .*
      Seeds: \s* (?<seeds>[\d,]+)
      \s+
      Peers: \s* (?<peers>[\d,]+)
      \s+
      Hash: \s* (?<hash>[a-f0-9]+)
    /xi

    def search_torrents(query)
      doc = document_for_query(query)
      doc.xpath(FEED_ITEMS_XPATH).map do |item|
        torrent_from_item(item)
      end
    end

    def torrent_from_item(item)
      desc = item.at_xpath('.//description').text
      matches = desc.match(FEED_DESC_REGEXP)
      exp = SIZE_UNITS.index(matches['size_unit'].downcase)
      size = matches['size'].to_i * (1024 ** exp)
      Torrent.new(
        title: item.at_xpath('.//title').text,
        url: item.at_xpath('.//link').text,
        seeds: matches['seeds'].gsub(",", "").to_i,
        peers: matches['peers'].gsub(",", "").to_i,
        size: size,
        hash: matches['hash']
      )
    end

    def document_for_query(query)
      url = FEED_TEMPLATE_URL.expand(query: query).to_s
      Nokogiri::XML HTTPClient.get(url)
    end

  end
end

