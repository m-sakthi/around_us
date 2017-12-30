class Post < ApplicationRecord
  # Associations
  belongs_to :user, inverse_of: :posts
  belongs_to :group, optional: true, inverse_of: :posts
  has_many :pictures, as: :imageable, dependent: :destroy
  belongs_to :parent, optional: true, class_name: Post.name
  has_many :children, class_name: Post.name, foreign_key: :parent_id

  # Callbacks
  before_save :set_status

  # Constants
  module Status
    FRESH = 'fresh'
    UPDATED = 'updated'
    ALL = Post::Status.constants.map{ |status| Post::Status.const_get(status) }.flatten.uniq
  end

  module Privacy
    FOLLOWERS = 'followers'
    FRIENDS = 'friends'
    COMMON = 'common'
    ALL = Post::Privacy.constants.map{ |privacy| Post::Privacy.const_get(privacy) }.flatten.uniq
  end

  RECORDS_LIMIT = 20

  enum status: Status::ALL
  enum privacy: Privacy::ALL

  # Validation
  validate :check_body_and_parent_id

  private
    def check_body_and_parent_id
      errors.add(:body, _('errors.cant_be_blank')) if self.body.blank? && self.parent_id.blank?
      if self.body.present?
        errors.add(:body, _(errors.is_too_long, max_length: AppSettings[:post][:max_length])
          ) if self.body.length > AppSettings[:post][:max_length]
      end
    end

    def set_status
      if self.body_changed?
        self.status = Status::UPDATED
      else
        self.status = Status::FRESH
      end
    end

end
