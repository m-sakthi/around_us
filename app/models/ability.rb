class Ability
  include CanCan::Ability

  def initialize(user)
    Role::Privileges::ALL.each do |privilege|
      can :"save_#{privilege}", User do |user|
        user.is_admin?
      end
    end

    # User
    can [:show, :profile, :index], User do |u|
      user.active?
    end

    can [:block, :activate, :destroy, :users_list], User do |u|
      user.is_admin?
    end

    can [:update], User do |u|
      u == user || user.is_admin?
    end

    # Post
    can :create, [Post, Picture] do |post|
      user.active?
    end

    can [:index, :show], Post do |post|
      user.active? && post.user == user #( post.user == user || user.followers.include? post.user )
    end

    can [:update, :destroy], Post do |post|
      user == post.user
    end

    # Picture
    can [:index, :show, :destroy], Picture do |picture|
      picture.owner == user
    end
  end
end
