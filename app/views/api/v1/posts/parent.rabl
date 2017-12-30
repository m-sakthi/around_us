object @parent_post
@parent_post ||= locals[:object]

attributes :id, :body, :created_at, :updated_at

node :pictures do |parent_post|
  partial 'pictures/show', object: parent_post.pictures
end