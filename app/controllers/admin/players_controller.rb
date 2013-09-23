class Admin::PlayersController < Admin::MainController
   layout "admin"
  def index
    @user = User::User.all
  end

  def show
    @user = User::User.find(params[:id])
  end

  def new
  	@path = admin_players_path
    @user = User::User.new
  end

  def create
    @user = User::User.new(params[:user_user])
    @path = admin_players_path
    if @user.save
      redirect_to admin_players_path, :notice => "Successfully registered!"
    else
      render "new", :notice => "Registration failed"
    end
  end

  def edit
  	
    @user = User::User.find_by_id(params[:id])
    @path = admin_player_path(@user.id)
  end

  def update
    @user = User::User.find_by_id(params[:id])
	@path = admin_player_path(@user.id)
    if @user.update_attributes(params[:user_user])
      redirect_to admin_player_path(@user.id), notice: 'Successfully updated.'
    else
      render "edit"
    end
  end

  def destroy
    @user = User::User.find_by_id(params[:id])
    
    unless @user.destroy
      redirect_to(admin_players_path, notice: "An error occured, the deletion was not successful")
    else
      redirect_to(admin_players_path, notice: "Player was destroyed")
    end
  end
end