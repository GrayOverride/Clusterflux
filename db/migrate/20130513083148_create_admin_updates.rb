class CreateAdminUpdates < ActiveRecord::Migration
  def change
    create_table :admin_updates do |t|
      t.string :title
      t.string :desc

      t.timestamps
    end
  end
end
