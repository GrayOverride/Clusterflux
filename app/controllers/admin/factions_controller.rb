class Admin::FactionsController < Admin::MainController
  layout "admin"
  def index
    @factions = ::Faction.all
  end

  def new
    @faction = ::Faction.new
    @path = admin_factions_path
  end

  def create
    @faction = ::Faction.new(params[:faction])
    
    if @faction.save
      redirect_to admin_factions_path, :notice => "A new faction was created"
    else
      render "new", :notice => "An error occured, the faction was not saved"
    end
  end

  def edit
    @faction = ::Faction.find_by_id(params[:id])
    @path = admin_faction_path(@faction.id)
  end

  def update
    @faction = ::Faction.find_by_id(params[:id])

    if @faction.update_attributes(params[:faction])
        redirect_to admin_factions_path, notice: 'Successfully updated.'
      else
        render "edit"
      end
  end

  def destroy
    @faction = ::Faction.find_by_id(params[:id])
    
    if @faction.destroy
      redirect_to(admin_factions_path, notice: "A faction was deleted")
    else
      redirect_to(admin_factions_path, notice: "An error occured, the deletion was not successful")
    end
  end
end
