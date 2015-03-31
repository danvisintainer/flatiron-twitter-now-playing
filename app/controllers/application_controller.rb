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
    RSpotify::Track.search(query).max_by {|t| t.popularity} 
  end

  def get_spotify_objects(tweets)
    tweets.collect do |tweet|
      {
        song: match_with_spotify(sanitize_track(tweet.text)),
        tweet_object: tweet,
        tweet_user_object: tweet.user
      }
    end
  end

  def get_tweets_using_client
    array = nil;
    max_id = nil;

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

    array
  end

  def get_now_playing_tweets(array)
    now_playing_list = array.select do |t| 
      !!(t.text.downcase =~ /nowplaying|now playing|\#np|musicmonday|music monday|tunestuesday|tunes tuesday/i)
    end

    now_playing_list
  end

  def get_tweets
    get_now_playing_tweets(get_tweets_using_client)
  end

end

def sanitize_track(tweet)
string = tweet
binding.pry
end