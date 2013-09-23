class AddKeyToServer < ActiveRecord::Migration
  def change
    add_column :servers, :key, :string
  end
end
