object @post

attributes :id, :body, :created_at, :updated_at

node :pictures do
  partial 'pictures/show', object: @post.pictures
end