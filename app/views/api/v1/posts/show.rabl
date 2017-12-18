object @post

attributes :id, :body, :created_at, :updated_at

node :user do |post|
  partial 'users/mini_show', object: post.user
end

pictures = @post.pictures
node :pictures, if: pictures.present? do
  partial 'pictures/show', object: pictures
end