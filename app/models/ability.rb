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

    # Create Post and Picture
    can :create, [Post, Picture, Group] do |post|
      user.active?
    end

    # Post
    can [:index, :show], Post do |post|
      user.active? && post.user == user #( post.user == user || user.followers.include? post.user )
    end

    can [:update, :destroy], Post do |post|
      post.user == user
    end

    # Picture
    can [:index, :show, :destroy], Picture do |picture|
      picture.owner == user
    end

    # Group
    can :index, Group do |group|
      user.active?
    end

    can [:show, :members], Group do |group|
      user.active? && group.visibility == Group::Visibility::PUBLIC ?
        true : group.member?(user.id)
    end

    can [:update, :destroy, :add_members, :update_privilege, :remove_members], Group do |group|
      group.can?(user.id, UsersGroup::Privilege::ADMIN) || user.is_admin?
    end
  end
end
