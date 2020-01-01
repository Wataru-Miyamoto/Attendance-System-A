class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :affiliation
      t.integer :employee_number
      t.string :uid
      t.boolean :superior, default: false
      t.boolean :admin, default: false
      t.string :password_digest
      t.string :remember_digest

      t.timestamps
    end
  end
end
