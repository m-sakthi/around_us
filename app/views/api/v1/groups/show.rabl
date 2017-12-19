object @group

attribute :id, :name, :purpose, :visibility, :created_at

node :members_count do |group|
  group.users_groups.count(1)
end

node :creator do |group|
  partial 'users/tiny_show', object: group.creator
end
