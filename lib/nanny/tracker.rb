require 'timeout'
require "nokogiri"

module Nanny
  class Tracker
    attr_reader :tracker_url

    class MagnetNotFound < RuntimeError; end
    class TorrentNotFound < RuntimeError; end
    class PageNotAvailable < RuntimeError; end

    def initialize(url)
      @tracker_url = url
    end

    def magnet_uri(progress = Progress.new)
      link = progress.step do
        tracker_doc.at_css("a[href^='magnet:']")
      end
      link or raise MagnetNotFound
      MagnetURI.new(link['href'])
    rescue PageNotAvailable
      raise MagnetNotFound
    ensure
      progress.complete!
    end

    def torrent_url(progress = Progress.new)
      progress.step do
        links = plausible_torrent_links
        progress.todo(links.count)
        links.each do |url|
          is_torrent = torrent_content_type?(url)
          progress.done!(1)
          return url if is_torrent
        end
      end
      raise TorrentNotFound
    rescue PageNotAvailable
      raise TorrentNotFound
    ensure
      progress.complete!
    end

    def plausible_torrent_links
      tracker_doc.css("a[href]").select do |link|
        valid_url?(link['href'])
      end.map do |link|
        to_absolute_url(link['href'])
      end.uniq
    end

    def to_absolute_url(url)
      uri = Addressable::URI.parse(url)
      if uri.absolute?
        url
      else
        Addressable::URI.parse(tracker_url).join(url).to_s
      end
    end

    def valid_url?(url)
      url =~ /\.torrent$/ && Addressable::URI.parse(url)
    rescue Addressable::URI::InvalidURIError
      false
    end

    def torrent_content_type?(url)
      thread = Thread.new {
        Thread.current[:headers] = begin
                                     HTTPClient.headers(url)
                                   rescue HTTPClient::Exception
                                     nil
                                   end
      }.join(2)
      thread && thread[:headers] or raise PageNotAvailable
      thread[:headers][:content_type] =~ /bittorrent|octet/
    end

    def tracker_doc
      @tracker_doc ||= begin
        thread = Thread.new {
          Thread.current[:data] = begin
                                    HTTPClient.get(tracker_url)
                                  rescue HTTPClient::Exception
                                    nil
                                  end
        }.join(2)
        thread && thread[:data] or raise PageNotAvailable
        Nokogiri::HTML(thread[:data])
      end
    end

  end
end

