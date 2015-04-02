class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  RSpotify::authenticate(ENV["SPOTIFY_KEY"], ENV["SPOTIFY_SECRET"])

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = ENV["TWITTER_KEY"]
      config.consumer_secret = ENV["TWITTER_SECRET"]
      config.access_token = session['access_token']
      config.access_token_secret = session['access_token_secret']
    end
  end

  def minimize_query(query)
    if !!/".*"/.match(query) # first, see if the song has quotes, and then try to match that
      # binding.pry
      puts "    Searching with quotes for #{/".*"/.match(query).to_s.gsub("\"", "")}"
      result = RSpotify::Track.search(/".*"/.match(query).to_s.gsub("\"", "")).max_by {|t| t.popularity}
      puts "     ^ Matched within quotes." if !result.nil?
      if result.nil?
        # binding.pry
        result = RSpotify::Track.search(query.gsub("\"", "").gsub(/tune\b|song\b|track\b|music\b|by\b|de\b|di\b/i, "")).max_by {|t| t.popularity} 
      end

      return result if !result.nil?
    end

    if !!/ft\b-/.match(query) # now, if the query has "ft. etc" in it (this seems to throw off spotify results)
      # binding.pry
      query.gsub!(/ft\b-/i, " ")
    end

    if !!/feat\b-/.match(query) # now, if the query has "ft. etc" in it (this seems to throw off spotify results)
      # binding.pry
      query.gsub!(/feat\b-/i, " ")
    end

    query = query.split
    center = query.index("-") || query.index("by") || query.index("/")

    return nil if center.nil?
    return nil if query[center-3..center+3].nil?

    q = query[center-3..center+3].join(" ").gsub("-", " ").gsub("by", " ")
    q.gsub!(/tune\b|song\b|track\b|music\b|by\b|de\b|di\b/i, "")

    if q.empty?
      return nil
    else
      puts "    Searching (with minimization) for #{q}"
      match = RSpotify::Track.search(q).max_by {|t| t.popularity}
      puts "     ^ Matched with minimized string." unless match.nil?
      return match
    end
  end

  def match_with_spotify(query)
    puts "  Searching Spotify for \"#{query}\""
    match = RSpotify::Track.search(query).max_by {|t| t.popularity} 

    match = minimize_query(query) if match.nil?
    puts "     ^ A Spotify match!" unless match.nil?
    puts "    No match." if match.nil?
    match
  end

  def sanitize_track(tweet)
    tweet = tweet.split
    tweet.delete_if do |t|
      t[0] == "\#" || t[0] == "@" || t.include?("http") || t.include?('♬') ||
      t.include?(':') || t.include?('♫') || t.include?('♩') || t == 'RT' ||
      t == "&amp;" || t.downcase == "on"
    end

    puts " Sanitized to #{tweet.join(' ')}"
    tweet.join(' ')
  end

  def get_spotify_objects(tweets)
    tweets.collect do |tweet|
      puts "Sanitizing tweet: #{tweet.text}"
      sanitized = sanitize_track(tweet.text)
      next if sanitized.empty?
      matched_song = match_with_spotify(sanitized)
      if !matched_song.nil?
        # binding.pry
        song_text = "#{matched_song.name} by #{matched_song.artists[0].name}"
      else
        song_text = tweet.text
      end

      {
        song_text: song_text,
        song_object: matched_song,
        tweet_object: tweet
      }
    end
  end

  def get_friend_tweets_using_client
    array = nil;
    max_id = nil;

    puts "Getting tweets..."
    5.times do
      begin
        if max_id.nil?
          array = client.home_timeline({count: 200})
          max_id = array.last.id
          puts "Max ID is now #{max_id}"
        else
          array << client.home_timeline({count:200, max_id: max_id})
          array.flatten!
          max_id = array.last.id
          puts "Max ID is now #{max_id}"
        end
      rescue Twitter::Error::TooManyRequests => error
        return
      end
    end

    puts "Done."
    array
  end

  def get_now_playing_tweets(array)
    now_playing_list = array.select do |t| 
      !!(t.text.downcase =~ /nowplaying|now playing|\#np\b/i)
    end

    now_playing_list
  end

  def get_tweets
    tweets = get_friend_tweets_using_client
    get_now_playing_tweets(tweets) unless tweets.nil?
  end

  def get_public_tweets
    client.search("\#nowplaying", result_type: "recent").take(20)
  end

end

def sanitize_track(tweet)
string = tweet
binding.pry
end