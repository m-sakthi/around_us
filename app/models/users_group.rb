class UsersGroup < ApplicationRecord
  belongs_to :user, inverse_of: :users_groups
  belongs_to :group, inverse_of: :users_groups

  # Callbacks
  before_validation :set_default_privilege, if: lambda { |record| record[:privilege].blank? }

  # Scopes
  scope :members_except, -> (privilege) { where.not(privilege: privilege) }

  # Constants
  # Privileges that the user has on the contents posted in the group
  module Privilege
    VIEW = "can_view" # Default - Only view posts
    COMMENT = "can_comment" # View and comment posts
    CREATE = "can_create" # View, comment and create posts
    ADMIN = "admin" # View, comment, create and delete posts
    ALL = UsersGroup::Privilege.constants.map{ |privilege| UsersGroup::Privilege.const_get(privilege) }.flatten.uniq
  end

  enum privilege: Privilege::ALL

  # Validations
  validates :user_id, presence: true
  validates :group_id, presence: true
  validates :user_id, uniqueness: { scope: :group_id }
  validates :privilege, inclusion: { in: Privilege::ALL }
  validate  :max_members

  private
    # Private - sets default can_view privilege
    def set_default_privilege
      self.privilege ||= Privilege::VIEW
    end

    # Private - Checks for the maximum members in a group
    def max_members
      self.errors.add(:group, _('errors.groups.max_members_limit_reached')
        ) if UsersGroup.where(group_id: self.group_id).count(1) >= AppSettings[:group][:max_members]
    end
end
