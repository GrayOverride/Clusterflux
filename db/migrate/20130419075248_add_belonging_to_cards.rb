class AddBelongingToCards < ActiveRecord::Migration
  def change
    add_column :cards, :faction_id, :integer
    add_column :cards, :type_id, :integer
  end
end
