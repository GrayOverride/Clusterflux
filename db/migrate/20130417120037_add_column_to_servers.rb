class AddColumnToServers < ActiveRecord::Migration
  def change
    add_column :servers, :state, :text
  end
end
