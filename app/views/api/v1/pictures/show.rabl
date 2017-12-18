object @picture

attributes :id, :imageable_id, :imageable_type

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

node :urls do |picture|
  partial 'pictures/style', object: picture
end