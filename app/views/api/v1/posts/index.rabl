object false

node :posts do
  partial 'posts/list', object: @posts
end

node :users do
  partial 'users/list', object: @posts.collect(&:user).uniq
end

node :groups do
  partial 'groups/list', object: @posts.collect(&:group).uniq.compact
end