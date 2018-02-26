class CreateRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :requests do |t|
      t.references :user, foreign_key: true
      t.integer :friend_id
      t.integer :status

      t.timestamps
    end
    add_index :requests, :friend_id
    add_index :requests, [:user_id, :friend_id], unique: true
  end
end
