object @users_group

node false do |users_group|
  partial 'users/mini_show', object: users_group.user
end

attributes :privilege

node :joined_at do |users_group|
  users_group.created_at
end