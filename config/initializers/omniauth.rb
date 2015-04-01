Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV["TWITTER_KEY"], ENV["TWITTER_SECRET"]
  provider :spotify, ENV["SPOTIFY_KEY"], ENV["SPOTIFY_SECRET"], scope: 'user-read-email playlist-modify-public user-library-read user-library-modify'
end