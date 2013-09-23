class AddColumnToCards < ActiveRecord::Migration
  def change
    add_column :cards, :publish, :boolean
  end
end
