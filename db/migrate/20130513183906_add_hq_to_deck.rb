class AddHqToDeck < ActiveRecord::Migration
  def change
    add_column :decks, :hq, :integer
  end
end
