object @post

node false do |post|
  partial 'posts/show_extension', object: post
end

node :parent do |post|
  partial 'posts/show_extension', object: post.parent
end