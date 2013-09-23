class Game::ServersController < Game::GamesController
  layout "application"
  #includes helper methods
  include Game::ServersHelper

  def index
  	@servers = Game::Server.where("publish = true")
    if @current_user
      @decks = @current_user.decks.all
    else
      @decks = User::Deck.where("user_id = 0")
    end
  end

  def new
  	@server = Game::Server.new
    
    if @current_user
      @decks = @current_user.decks.all
    else
      @decks = User::Deck.where("user_id = 0")
    end
  end

  def create
  	@server = Game::Server.new(params[:server])
    @server.publish = true #let user decide to publish to browser or not?
    @server.ready = false #is the server full or not
    @server.key = SecureRandom.uuid

    if params[:deck]
      if @current_user
        @server.user_id = session[:user_id]
        deck = User::Deck.where("id = ? AND user_id = ?", params[:deck], @current_user.id).first
      else
        @server.username = session[:username]
        deck = User::Deck.where("id = ? AND user_id = 0", params[:deck]).first
      end

      @server.state = Hash.new
      @server.state["player_1"] = {"ready" => false}

      session[:player] = "player_1"

      #build the deck
      cards = fetch_cards(@server, deck)
    end

    if cards && @server.save
      if @current_user
    	  @creator = @server.user.username
      else
        @creator = @server.username
      end

    	#url to published server (for users other than creator)
    	@url = game_join_path(@server.key)

    	#publish server to serverbrowser and redirect creator to the board
    	PrivatePub.publish_to("/servers/new", :server => @server, :creator => @creator, :url => @url)
      session[:turn] = false

      redirect_to game_board_path(@server.key), :notice => "Game started"
    else
      if @current_user
        @decks = @current_user.decks.all
      else
        @decks = User::Deck.where("user_id = 0")
      end

      render "new", :notice => "Game failed to start"
    end
  end

  def join
  	@server = Game::Server.where("key = ? AND ready = false", params[:key]).first
    response = Hash.new
    response["result"] = false

  	if @server && params[:deck]
      if @server.state["player_1"]
        @server.state["player_2"] = {"ready" => false}
        session[:player] = "player_2"
      else
        @server.state["player_1"] = {"ready" => false}
        session[:player] = "player_1"
      end

  		if @server.update_attributes(:publish => false, :ready => true, :state => @server.state)
        #remove server from serverbrowser since it is full (creator + other)
  			PrivatePub.publish_to("/servers/remove", :key => @server.key)

        if @current_user
          deck = User::Deck.where("id = ? AND user_id = ?", params[:deck], @current_user.id).first
        else
          deck = User::Deck.where("id = ? AND user_id = 0", params[:deck]).first
        end

        #temp deck
        cards = fetch_cards(@server, deck)

	  		#redirect joiner to game board
	  		#redirect_to game_board_path(@server.key), :notice => "Joined " + @server.name

        response["result"] = true
        response["path"] = game_board_path(@server.key)

        session[:turn] = false

        respond_to do |format|
          format.json { render :json => response }
        end
	  	else
	  		respond_to do |format|
          format.json { render :json => response }
        end
	  	end
  	else
  		respond_to do |format|
        format.json { render :json => response }
      end
  	end
  end
end
