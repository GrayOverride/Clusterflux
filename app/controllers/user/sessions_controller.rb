class User::SessionsController < User::MainController
  skip_before_filter :authenticate, :only => [:new, :create]

  def new
  end

  def create
  	user = User::User.authenticate(params[:creds], params[:password])
  	if user
  		session[:user_id] = user.id

  		redirect_to game_servers_path, :notice => "Logged in!"
  	else
  		flash.now.alert = "Invalid credentials"
  		redirect_to root_path

  	end
  end

  def destroy
  	session[:user_id] = nil
  	redirect_to root_url, :notice => "Logged out!"
  end
end
