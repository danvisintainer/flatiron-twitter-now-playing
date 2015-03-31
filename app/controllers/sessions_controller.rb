class SessionsController < ApplicationController

  def create
    session[:access_token] = request.env['omniauth.auth']['credentials']['token']
    session[:access_token_secret] = request.env['omniauth.auth']['credentials']['secret']
    redirect_to show_path
  end

  def show
    if session['access_token'] && session['access_token_secret']
      @user = client.user(include_entities: true)
      @now_playing_list = get_spotify_objects(get_tweets)
    else
      redirect_to failure_path
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

end
