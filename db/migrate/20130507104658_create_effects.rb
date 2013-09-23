class CreateEffects < ActiveRecord::Migration
  def change
    create_table :effects do |t|
      t.string :name
      t.string :type
      t.string :effect
      t.integer :amount

      t.timestamps
    end
  end
end
