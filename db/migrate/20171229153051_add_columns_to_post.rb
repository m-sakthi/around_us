class AddColumnsToPost < ActiveRecord::Migration[5.1]
  def change
    add_reference :posts, :group, foreign_key: true
    add_column :posts, :status, :integer, default: 0
    add_column :posts, :parent_id, :integer
    add_column :posts, :privacy, :integer

    add_index :posts, :parent_id
  end
end
