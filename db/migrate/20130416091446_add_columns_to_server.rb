class AddColumnsToServer < ActiveRecord::Migration
  def change
    add_column :servers, :username, :string
    add_column :servers, :full, :boolean
  end
end
