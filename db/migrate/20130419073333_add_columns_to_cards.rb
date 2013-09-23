class AddColumnsToCards < ActiveRecord::Migration
  def change
    add_column :cards, :upkeep, :integer
    add_column :cards, :energy, :integer
    add_column :cards, :atk, :integer
    add_column :cards, :def, :integer
    add_column :cards, :gank, :integer
  end
end
