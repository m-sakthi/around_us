class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :email, :null => false
      t.string :user_name
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.integer :status, :null => false, :default => 0
      t.string :activation_digest
      t.datetime :activated_at
      t.string :reset_digest
      t.datetime :reset_sent_at
      t.string :authentication_token

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :user_name, unique: true
  end
end
