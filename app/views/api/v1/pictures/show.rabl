object @picture

attributes :id

node :name do |picture|
  picture.image_file_name
end

node :content_type do |picture|
  picture.image_content_type
end

node :size do |picture|
  picture.image_file_size
end

node :picture_type do |picture|
  picture.picture_type
end

node :updated_at do |picture|
  picture.image_updated_at
end

node :parent_id do |picture|
  picture.imageable_id
end

node :parent_type do |picture|
  picture.imageable_type
end