class Group < ApplicationRecord
  # Associations
  belongs_to :creator, foreign_key: :user_id, class_name: User.name
  has_many :users_groups, dependent: :destroy, inverse_of: :group
  has_many :users, through: :users_groups

  # Scopes
  scope :visibility, -> (visibility) { where(visibility: visibility) }

  # Callbacks
  before_validation :set_default_visibility, if: lambda { |group| group.visibility.blank? }
  after_create :add_creator_as_admin

  # Constants
  module Visibility
    DELETED = 0
    PRIVATE = 1
    PUBLIC = 2
    ALL = Group::Visibility.constants.map{ |v| Group::Visibility.const_get(v) }.flatten.uniq
  end

  RECORDS_LIMIT = 20

  # Validations
  validates :user_id, presence: true
  validates :name, presence: true, length: { minimum: 3, maximum: 50 }
  validates :purpose, allow_blank: true, length: { maximum: 250 }
  validates :visibility, inclusion: { in: Visibility::ALL }
  validate  :valid_visibility, on: :create

  # Public - Adds user to UserGroup via Group
  # user_id : integer
  # returns UserGroup object or Error object of Group
  def add_user(user_id, privilege = nil)
    users_group = self.users_groups.build(user_id: user_id, privilege: privilege)
    if users_group.valid?
      users_group.save
    else
      error = users_group.errors
      key = error.keys.first
      self.errors[key].push _('errors.groups.error_message', message: error[key].first, user_id: user_id)
      self.errors
    end
  end

  # Public - Adds users to UserGroup via Group
  # user_ids : Array of user_id
  # returns true or Error object of Group
  def add_multiple_users(user_ids, privilege = nil)
    user_ids_arr = user_ids
    users_group = nil
    user_ids_arr.each do |user_id|
      self.add_user(user_id, privilege)
    end
    self.errors.present? ? self.errors : true
  end

  # Public - Adds user to UserGroup via Group and gives admin privilege
  # returns UserGroup object or Error object of Group
  def add_creator_as_admin
    self.add_user(self.user_id, UsersGroup::Privilege::ADMIN)
  end

  def remove_users(user_ids)
    self.users_groups.where(user_id: user_ids).delete_all
    members = self.users_groups
    if members.present?
      members.order(:created_at).admin! if members.admin.blank?
    else
      self.update(visibility: Visibility::DELETED)
    end
  end

  def member?(user_id)
    self.users_groups.exists?(user_id: user_id)
  end

  # Public - Checks if the user has privilege to perform the operation
  # Returns boolean
  def can?(user_id, privilege)
    users_group = self.users_groups.where(user_id: user_id)
    return false if users_group.blank?
    UsersGroup.privileges[privilege] <= UsersGroup.privileges[users_group.first.privilege]
  end

  # Public - Assigns default visibility
  def set_default_visibility
    self.visibility ||= Visibility::PUBLIC
  end

  # Public - Error added if group with status deleted is created
  def valid_visibility
    self.errors.add(:visibility, _('errors.groups.cannot_assign_deleted_visibility')
      ) if self.visibility == Visibility::DELETED
  end
end