class User::UsersController < User::MainController
  skip_before_filter :authenticate, :only => [:new, :create]

  def show
    @user = User::User.find(params[:id])
  end

  def new
    @user = User::User.new
  end

  def create
    @user = User::User.new(params[:user])
    
    if @user.save
      redirect_to root_url, :notice => "Successfully registered!"
    else
      render "new", :notice => "Registration failed"
    end
  end

  def edit
    @user = User::User.find_by_id(params[:id])
  end

  def update
    @user = User::User.find_by_id(params[:id])

    if @user.update_attributes(params[:user])
        redirect_to user_show_path(@user.id), notice: 'Successfully updated.'
      else
        render "edit"
      end
  end

  def destroy
    @user = User::User.find_by_id(params[:id])
    
    if @user.destroy    
      redirect_to root_url
    else
      redirect_to(user_show_path(@user.id), notice: "An error occured, the deletion was not successful")
    end
  end
end
