class CreateUsersGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :users_groups do |t|
      t.references :user, foreign_key: true, index: true
      t.references :group, foreign_key: true, index: true
      t.integer :privilege, default: 0

      t.timestamps
    end
    add_index :users_groups, [:user_id, :group_id], unique: true
  end
end
