require 'active_support/core_ext/string/strip'
require 'trollop'
require 'terminal-table'
require 'colored'
require 'highline'
require 'ruby-progressbar'

module Nanny
  class CLI

    def run!
      options = process_options!

      if query.size.zero?
        Trollop::die "A query is required"
      end

      torrents = Nanny::Search.new.search_torrents(query)
      results_range = 0 .. options[:limit] - 1

      puts formatted_torrents(torrents[results_range])
      puts
      torrent_index = highline.ask("Choose a torrent to download", Integer) do |q|
        q.default = 0
        q.in = results_range
      end
      torrent = torrents[torrent_index]

      puts

      bar = ProgressBar.create(title: "Searching")
      progress = Progress.new do |p|
        bar.progress = 100.0 * p.total_done / p.total_todo
      end

      highline.say torrent.torrent_url(progress)
    end

    def formatted_torrents(torrents)
      rows = torrents.each_with_index.map do |torrent, i|
        [
          i,
          truncate_string(torrent.title),
          torrent.human_size,
          torrent.seeds.to_s.red,
          torrent.peers.to_s.green
        ]
      end
      rows = [
        [ "#", "Title", "Size", "Seeds", "Peers" ],
        :separator
      ] + rows
      Terminal::Table.new(rows: rows).to_s
    end

    def process_options!
      Trollop::options do
        banner <<-RAW.strip_heredoc

        nanny is your friendly and lovely torrent finder

        Usage:
          nanny [options] <query>

        Options:
        RAW
        version "Nanny #{Nanny::VERSION} (c) Stefano Verna"
        opt :limit, "The number of results", default: 5
      end
    end

    def query
      ARGV.join(" ")
    end

    def truncate_string(text)
      if text.size > 50
        text[0..50] + "..."
      else
        text
      end
    end

    def highline
      @highline ||= HighLine.new
    end

  end
end

