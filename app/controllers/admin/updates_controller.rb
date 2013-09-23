class Admin::UpdatesController < Admin::MainController
   layout "admin"
  # GET /admin/updates
  # GET /admin/updates.json
  def index
    @admin_updates = Admin::Update.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_updates }
    end
  end

  # GET /admin/updates/1
  # GET /admin/updates/1.json
  def show

    @admin_update = Admin::Update.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_update }
    end
  end

  # GET /admin/updates/new
  # GET /admin/updates/new.json
  def new
    @admin_update = Admin::Update.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_update }
    end
  end

  # GET /admin/updates/1/edit
  def edit
    @admin_update = Admin::Update.find(params[:id])
  end

  # POST /admin/updates
  # POST /admin/updates.json
  def create
    @admin_update = Admin::Update.new(params[:admin_update])

    respond_to do |format|
      if @admin_update.save
        format.html { redirect_to @admin_update, notice: 'Update was successfully created.' }
        format.json { render json: @admin_update, status: :created, location: @admin_update }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_update.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/updates/1
  # PUT /admin/updates/1.json
  def update
    @admin_update = Admin::Update.find(params[:id])

    respond_to do |format|
      if @admin_update.update_attributes(params[:admin_update])
        format.html { redirect_to @admin_update, notice: 'Update was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_update.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/updates/1
  # DELETE /admin/updates/1.json
  def destroy
    @admin_update = Admin::Update.find(params[:id])

    if @admin_update.destroy
      redirect_to(admin_updates_path, notice: "A type was deleted")
    else
      redirect_to(admin_updates_path, notice: "An error occured, the deletion was not successful")
    end
  end
end
