class Game::BoardController < Game::GamesController
  before_filter :key_auth, :checkPlayer

  #includes helper methods
  include Game::BoardHelper

  #changes layout for the board (this also includes different js files)
  layout "board"

  def index
  	@server = Game::Server.where("key = ?", params[:key]).first

    session[:key] = @server.key
    @player = session[:player]

    #get faction
    @faction = @server.state[session[:player]]["deck"][0]["faction"]

    send_message("System", fetch_username + " joined the game")
  end

  def chat
    if session[:key] == params[:key]
      chat_message
    end
    render :nothing => true
  end

  def ready
    if session[:key] == params[:key]
      set_ready
    end
    render :nothing => true
  end

  def disconnect
    if session[:key] == params[:key]
      if disconnect_player
        redirect_to game_servers_path, :notice => "You were disconnected"
      end
    end
  end

  # check if server exists
  private
  def key_auth
    server = Game::Server.where("key = ?", params[:key]).first

    #if server does not exist in db, redirect to server browser
    unless server
      redirect_to game_servers_path, :notice => "Couldn't access game"
    end
  end
end
