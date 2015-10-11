class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :address
      t.string :tel
      t.integer :height
      t.integer :weight
      t.text :remarks
      t.text :comment

      t.timestamps null: false
    end
  end
end
