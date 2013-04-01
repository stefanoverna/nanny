module Nanny
  class MagnetURI
    attr_reader :uri

    def initialize(uri)
      @uri = uri
    end

    def hash
      uri.match(/xt=urn:btih:(?<hash>[a-z0-9]+)/i)["hash"]
    end

  end
end

