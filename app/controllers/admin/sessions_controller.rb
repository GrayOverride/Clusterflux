class Admin::SessionsController < Admin::MainController
  skip_before_filter :authenticate, :only => [:new, :create]
 layout "application"
  def new
  end

  def create
  	user = Admin::User.authenticate(params[:username], params[:password])
  	if user
  		session[:admin_id] = user.id

  		redirect_to admin_home_path, :notice => "Logged in!"
  	else
  		flash.now.alert = "Invalid credentials"
  		render "new", :notice => "Invalid credentials"
  	end
  end

  def destroy
  	session[:admin_id] = nil
  	redirect_to root_url, :notice => "Logged out!"
  end
end
