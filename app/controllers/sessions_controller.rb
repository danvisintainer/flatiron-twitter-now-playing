class SessionsController < ApplicationController

  def create
    session[:access_token] = request.env['omniauth.auth']['credentials']['token']
    session[:access_token_secret] = request.env['omniauth.auth']['credentials']['secret']
    redirect_to '/show/friends'
  end

  def show
    if params[:mode] == 'friends'
      if session['access_token'] && session['access_token_secret']
        @user = client.user(include_entities: true)
        @now_playing_list = get_spotify_objects(get_tweets)
        session['playlist'] = @now_playing_list.collect {|s| s[:song_object].id unless s[:song_object].nil?}.compact
      else
        redirect_to failure_path
      end
    elsif params[:mode] == 'public'
      @now_playing_list = get_spotify_objects(get_public_tweets)
      session['playlist'] = @now_playing_list.collect {|s| s[:song_object].id unless s[:song_object].nil?}.compact
    else
      redirect_to root_path
    end

  end

  def error
    flash[:error] = 'Sorry, an unexpected error has occurred! Please try again.'
    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'Signed out'
  end

  def playlist
    spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    new_playlist = spotify_user.create_playlist!("Simplist - #{Date.today.to_formatted_s(:long_ordinal)}")
    spotify_songs = session['playlist'].collect {|s| RSpotify::Track.find(s)}
    new_playlist.add_tracks!(spotify_songs)
    redirect_to new_playlist.external_urls["spotify"]
  end

end
