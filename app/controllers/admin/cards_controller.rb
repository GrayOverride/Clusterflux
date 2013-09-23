class Admin::CardsController < Admin::MainController
  layout "admin"
  def index
    @cards = ::Card.order("updated_at DESC").all
  end

  def show
    @card = ::Card.find(params[:id])
  end

  def new
    @card = ::Card.new
    @path = admin_cards_path
  end

  def create
    @card = ::Card.new(params[:card])
    @path = admin_cards_path

    if @card.save
      redirect_to admin_cards_path, :notice => "A new card was created!"
    else
      render "new", :notice => "An error occured, the card was not saved"
    end
  end

  def edit
    @card = ::Card.find_by_id(params[:id])
    @path = admin_card_path(@card.id)
  end

  def update
    @card = ::Card.find_by_id(params[:id])

    if @card.update_attributes(params[:card])
        redirect_to admin_cards_path, notice: 'Successfully updated.'
      else
        render "edit"
      end
  end

  def destroy
    @card = ::Card.find_by_id(params[:id])
    
    unless @card.destroy
      redirect_to(admin_cards_path, notice: "An error occured, the deletion was not successful")
    else
      redirect_to(admin_cards_path, notice: "The card was deleted")
    end
  end
end
