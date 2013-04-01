require 'addressable/template'

module Nanny
  class Torcache
    TORCACHE_URL = Addressable::Template.new("http://torcache.net/torrent/{hash}.torrent")
    TORRAGE_URL = Addressable::Template.new("http://torrage.com/torrent/{hash}.torrent")

    class HashNotFound < RuntimeError; end

    def self.url_for(hash)
      [ TORCACHE_URL, TORRAGE_URL ].each do |template|
        begin
          url = template.expand(hash: hash.upcase).to_s
          HTTPClient.headers(url)
          return url
        rescue HTTPClient::Exception
        end
      end
      raise Torcache::HashNotFound
    end

  end
end

