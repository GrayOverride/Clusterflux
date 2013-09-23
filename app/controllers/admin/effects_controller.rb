class Admin::EffectsController < Admin::MainController
  layout "admin"
  def index
    @effects = ::Effect.all
  end

  def show
    @effect = ::Effect.find(params[:id])
  end

  def new
    @effect = ::Effect.new
    @path = admin_effects_path
  end

  def create
    @effect = ::Effect.new(params[:effect])
    @path = admin_effects_path

    if @effect.save
      redirect_to admin_effects_path, :notice => "A new effect was created!"
    else
      render "new", :notice => "An error occured, the effect was not saved"
    end
  end

  def edit
    @effect = ::Effect.find_by_id(params[:id])
    @path = admin_effect_path(@effect.id)
  end

  def update
    @effect = ::Effect.find_by_id(params[:id])

    if @effect.update_attributes(params[:effect])
        redirect_to admin_effects_path, notice: 'Successfully updated.'
      else
        render "edit"
      end
  end

  def destroy
    @effect = ::Effect.find_by_id(params[:id])
    
    unless @effect.destroy
      redirect_to(admin_effects_path, notice: "An error occured, the deletion was not successful")
    else
      redirect_to(admin_effects_path, notice: "An effect was deleted")
    end
  end
end
