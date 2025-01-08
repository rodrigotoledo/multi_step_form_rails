class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :age
      t.text :address
      t.integer :step

      t.timestamps
    end
  end
end
