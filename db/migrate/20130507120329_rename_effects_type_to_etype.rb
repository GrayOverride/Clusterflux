class RenameEffectsTypeToEtype < ActiveRecord::Migration
  def up
  	rename_column :effects, :type, :etype
  end

  def down
  	rename_column :effects, :etype, :type
  end
end
