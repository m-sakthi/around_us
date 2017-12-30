object @post
@post = locals[:object]

attributes :id, :body, :user_id, :group_id, :status, :created_at, :updated_at

node :pictures do |post|
  partial 'pictures/show', object: post.pictures
end