class Admin::TypesController < Admin::MainController
   layout "admin"
  def index
    @types = ::Type.all
  end

  def show
    @type = ::Type.find(params[:id])
  end

  def new
    @type = ::Type.new
    @path = admin_types_path
  end

  def create
    @type = ::Type.new(params[:type])
    
    if @type.save
      redirect_to admin_types_path, :notice => "A new type was created"
    else
      render "new", :notice => "An error occured, the type was not saved"
    end
  end

  def edit
    @type = ::Type.find_by_id(params[:id])
    @path = admin_type_path(@type.id)
  end

  def update
    @type = ::Type.find_by_id(params[:id])

    if @type.update_attributes(params[:type])
        redirect_to admin_types_path, notice: 'Successfully updated.'
      else
        render "edit"
      end
  end

  def destroy
    @type = ::Type.find_by_id(params[:id])
    
    if @type.destroy
      redirect_to(admin_types_path, notice: "A type was deleted")
    else
      redirect_to(admin_types_path, notice: "An error occured, the deletion was not successful")
    end
  end
end
