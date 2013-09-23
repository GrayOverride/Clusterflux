class CreateAdminUsers < ActiveRecord::Migration
  def change
    create_table :admin_users do |t|
      t.string :username
      t.string :email
      t.string :pw_hash
      t.string :pw_salt

      t.timestamps
    end
  end
end
