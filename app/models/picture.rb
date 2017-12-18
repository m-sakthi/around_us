class Picture < ApplicationRecord
  # Callbacks
  before_save :unset_current_profile_or_cover, if: Proc.new { |picture| picture.picture_type.present? && Picture::PictureType::ALL.include?(picture.picture_type) }

  # Scopes

  # Associations
  belongs_to :imageable, polymorphic: true

  # Constants
  module PictureType
    PROFILE = 'profile'
    COVER = 'cover'
    ALL = Picture::PictureType.constants.map{ |status| Picture::PictureType.const_get(status) }.flatten.uniq
  end

  module ImagableType
    USER = 'User'
    POST = 'Post'
    ALL = Picture::ImagableType.constants.map{ |status| Picture::ImagableType.const_get(status) }.flatten.uniq
  end

  enum picture_type: [:profile, :cover]

  # Validations
  has_attached_file :image,
    styles: AppSettings[:picture][:styles].symbolize_keys,
    convert_options: AppSettings[:picture][:convert_options].symbolize_keys
  validates_attachment :image, 
    content_type: { content_type: AppSettings['picture']['content_types'] },
    presence: true, size: { in: 0..AppSettings['picture']['max_allowed_size'].megabytes }
  validates :picture_type, allow_nil: true, inclusion: { in: Picture::PictureType::ALL }
  validates :imageable_type, presence: true, inclusion: { in: Picture::ImagableType::ALL }
  validate :imageable_only_user, on: :create, if: -> (record) { record.picture_type.present? }

  # Class methods and Instance methods
  def owner
    self.imageable_type == ImagableType::USER ? self.imageable : self.imageable.user
  end

  def url(size = :original)
    image.url(size)
  end

  def unset_current_profile_or_cover
    picture = self.imageable.pictures.send(self.picture_type).first
    picture.update(picture_type: nil) if picture.present?
  end

  def imageable_only_user
    errors.add(:picture, _('errors.pictures.imageable_type_not_applicable', type: self.picture_type)
      ) if self.imageable_type == ImagableType::POST
  end
end
