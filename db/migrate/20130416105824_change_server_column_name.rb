class ChangeServerColumnName < ActiveRecord::Migration
  def up
    rename_column :servers, :full, :ready
  end

  def down
    rename_column :servers, :ready, :full
  end
end
