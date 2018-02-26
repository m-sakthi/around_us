object @request
attributes :status, :created_at

node :user do |request|
  partial 'users/mini_show', object: request.user
end