class CreatePictures < ActiveRecord::Migration[5.1]
  def change
    create_table :pictures do |t|
      t.attachment :image
      t.references :imageable, polymorphic: true, index: true
      t.integer :picture_type

      t.timestamps
    end
  end
end
