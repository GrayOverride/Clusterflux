class CreateGameServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :name
      t.boolean :publish

      t.timestamps
    end
  end
end
