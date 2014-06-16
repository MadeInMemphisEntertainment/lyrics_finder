require_relative 'lyrics_finder/dependencies'

module LyricsFinder
  class Fetcher
    PROVIDERS_LIST = [:lyrics_wikia]
    UsageError = Class.new(StandardError)

    def initialize(*args)
      @providers = filter_providers(args)
    end

    def search(author, title)
     validate_song_data(author, title)
      song_lyric = catch(:song_lyric) {
        @providers.each do |provider|
          klass = Providers.build_klass(provider)
          url = klass.format_url(author, title)

          data = perform_request(url)
          if data
            throw :song_lyric, klass.extract_lyric(data)
          end
        end
      }
    end
    
    private

    def filter_providers(providers)
      valid_providers = []
      providers.each do |provider|
        valid_providers << provider if PROVIDERS_LIST.include?(provider)
      end
      valid_providers.any? ? valid_providers : PROVIDERS_LIST
    end

    def validate_song_data(author, title)
      if author.blank? || title.blank?
        fail UsageError, "You must supply a valid author and title"
      end
    end

    def perform_request(url)
      begin
        open(url)
      rescue Exception => ex
        puts ex.message
      end
    end
  end
end