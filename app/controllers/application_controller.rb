class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = ENV["TWITTER_KEY"]
      config.consumer_secret = ENV["TWITTER_SECRET"]
      config.access_token = session['access_token']
      config.access_token_secret = session['access_token_secret']
    end
  end

  def match_with_spotify(query)
    
    # binding.pry
    # query = /\w/.match(query)
    puts "Searching Spotify for \"#{query}\""
    match = RSpotify::Track.search(query).max_by {|t| t.popularity} 

    puts "^ A Spotify match!" unless match.nil?
    match
  end

  def sanitize_track(tweet)
    tweet = tweet.split
    tweet.delete_if do |t|
      t[0] == "\#" || t[0] == "@" || t.include?("http") || t.include?('♬') ||
      t.include?(':') || t.include?('♫') || t.include?('♩') || t == 'RT' ||
      t == "&amp;" || t.downcase == "on"
    end

    tweet.join(' ')
  end

  def get_spotify_objects(tweets)
    tweets.collect do |tweet|
      matched_song = match_with_spotify(sanitize_track(tweet.text))
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

  def get_tweets_using_client
    # binding.pry
    array = nil;
    max_id = nil;

    puts "Getting tweets..."
    5.times do
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
    end
    puts "Done."

    # client.search("\#nowplaying", result_type: "recent").take(20)

    array
  end

  def get_now_playing_tweets(array)
    now_playing_list = array.select do |t| 
      !!(t.text.downcase =~ /nowplaying|now playing|\#np\b/i)
    end

    now_playing_list
  end

  def get_tweets
    get_now_playing_tweets(get_tweets_using_client)
  end

end
