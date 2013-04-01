require 'nokogiri'

module Nanny
  class Torrent
    include AttrInitializer

    attr_reader :title
    attr_reader :url
    attr_reader :size
    attr_reader :seeds
    attr_reader :peers
    attr_reader :hash

    class URLNotFound < RuntimeError; end

    def human_size
      return "0B" if size.zero?
      units = %w{B KB MB GB TB}
      e = (Math.log(size)/Math.log(1024)).floor
      s = "%.1f" % (size.to_f / 1024**e)
      s.sub(/\.?0*$/, units[e])
    end

    def torrent_url(progress = Progress.new)
      torcache_url(progress.child)
    rescue URLNotFound
      trackers_torrent_url(progress.child)
    ensure
      progress.complete!
    end

    def torcache_url(progress = Progress.new)
      progress.step { Torcache.url_for(hash) }
    rescue Torcache::HashNotFound
      trackers_torcache_url(progress.child)
    ensure
      progress.complete!
    end

    def trackers_torcache_url(progress = Progress.new)
      progress.step do
        trackers.each do |tracker|
          begin
            return progress.step do
              Torcache.url_for tracker.magnet_uri(progress.child).hash
            end
          rescue Tracker::MagnetNotFound
          rescue Torcache::HashNotFound
          end
        end
      end
      raise URLNotFound
    ensure
      progress.complete!
    end

    def trackers_torrent_url(progress = Progress.new)
      progress.step do
        trackers.each do |tracker|
          begin
            return tracker.torrent_url(progress.child)
          rescue Tracker::TorrentNotFound
          end
        end
      end
      raise URLNotFound
    ensure
      progress.complete!
    end

    def trackers
      page_doc.css(".download dl dt a[href^=http]").map do |link|
        Tracker.new(link['href'])
      end
    end

    def page_doc
      Nokogiri::HTML(page_html)
    end

    def page_html
      @page_html ||= HTTPClient.get(url)
    end

  end
end

