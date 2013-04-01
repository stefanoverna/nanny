require 'rest-client'

module Nanny
  class HTTPClient

    class Exception < RuntimeError; end

    def self.headers(url)
      RestClient.head(url).headers
    rescue URI::InvalidURIError
    rescue SocketError
    rescue RestClient::Exception
      raise Exception
    end

    def self.get(url)
      RestClient.get(url).body.force_encoding("utf-8")
    rescue URI::InvalidURIError
    rescue SocketError
    rescue RestClient::Exception
      raise Exception
    end

  end
end

