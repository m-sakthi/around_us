class CreateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :purpose
      t.references :user, foreign_key: true, index: true
      t.integer :visibility

      t.timestamps
    end
  end
end
