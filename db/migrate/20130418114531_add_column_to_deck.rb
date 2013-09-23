class AddColumnToDeck < ActiveRecord::Migration
  def change
    add_column :decks, :cards, :text
  end
end
