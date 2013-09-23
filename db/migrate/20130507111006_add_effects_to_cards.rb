class AddEffectsToCards < ActiveRecord::Migration
  def change
    add_column :cards, :scout_id, :integer
    add_column :cards, :flip_id, :integer
    add_column :cards, :deploy_id, :integer
    add_column :cards, :passive_id, :integer
  end
end
