class Relationship < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :follower, class_name: User.name

  # Validations
  validates :follower_id, presence: true
  validates_uniqueness_of :user_id, scope: :follower_id
  validate :self_assignment

  # Constants
  module RelationshipType
    FOLLOWER = 'follower'
    FRIEND = 'friend'
    ALL = Relationship::RelationshipType.constants.map{ |t| Relationship::RelationshipType.const_get(t) }.flatten.uniq
  end

  enum relationship_type: RelationshipType::ALL

  # Callbacks

  # Instance Methods
  def create_reverse_friendship
    if self.relationship_type == Relationship::RelationshipType::FRIEND
      relationship = Relationship.find_or_initialize_by(user_id: self.follower_id, follower_id: self.user_id)
      relationship.relationship_type = Relationship::RelationshipType::FRIEND
      relationship.save
    end
  end

  def destroy_reverse_friendship
    Relationship.friend.where(user_id: self.follower_id, follower_id: self.user_id)
      .delete_all if self.relationship_type == Relationship::RelationshipType::FRIEND
  end

  def friends?(user_id, friend_id)
    r = Relationship.friend.where(user_id: user_id, follower_id: friend_id).exists?
    Relationship.friend.where(user_id: user_id, follower_id: friend_id)
  end

  private
    def self_assignment
      errors.add(:user, _('errors.relationships.cannot_assign_self')
        ) if self.user_id.to_i == self.follower_id.to_i
    end

end
