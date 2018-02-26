class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :relationships do |t|
      t.references :user, foreign_key: true
      t.integer :follower_id
      t.integer :relationship_type, default: 0

      t.timestamps
    end
    add_index :relationships, :follower_id
    add_index :relationships, [:user_id, :follower_id], unique: true
  end
end
