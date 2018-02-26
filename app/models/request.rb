class Request < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: User.name

  validates :friend_id, presence: true
  validates_uniqueness_of :user_id, scope: :friend_id
  validate :check_status, on: :update
  validate :self_assignment
  validate :already_friends?

  after_commit :create_relationship, if: lambda { self.status == Request::Status::ACCEPTED }

  # Constants
  module Status
    FRESH = 'fresh'
    ACCEPTED = 'accepted'
    DECLINED = 'declined'
    ALL = Request::Status.constants.map{ |status| Request::Status.const_get(status) }.flatten.uniq
  end

  enum status: Status::ALL

  # Instance Methods
  def create_relationship
    relationship = self.user.relationships.find_or_initialize_by(follower_id: self.friend_id)
    relationship.relationship_type = Relationship::RelationshipType::FRIEND
    relationship.create_reverse_friendship if relationship.save
    # destroy_requests
  end

  # def destroy_requests
  #   Request.where(user_id: self.friend_id, friend_id: self.user_id).destroy_all
  #   self.destroy
  # end

  private
    def check_status
      errors.add(:status, :invalid) unless self.status.in?([Request::Status::ACCEPTED, Request::Status::DECLINED])
    end

    def self_assignment
      errors.add(:user, _('errors.relationships.cannot_assign_self')
        ) if self.user_id.to_i == self.friend_id.to_i
    end

    def already_friends?
      errors.add(:user, _('errors.relationships.already_friends')
        ) if Relationship.friends?(self.user_id.to_i, self.friend_id.to_i)
    end
end
