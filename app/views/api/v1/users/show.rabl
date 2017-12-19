object @user

@user ||= locals[:object]

attributes :id, :email, :user_name, :first_name, :last_name, :profile_pic, :type, :status, :created_at, :updated_at

profile_picture = @user.pictures.profile.first
node :profile, if: profile_picture.present?, object_root: false do
  partial 'pictures/style', object: profile_picture,
    locals: { styles: AppSettings[:picture][:styles].keys.map(&:to_sym).push(:original) }
end

cover_picture = @user.pictures.cover.first
node :profile, if: cover_picture.present?, object_root: false do
  partial 'pictures/style', object: cover_picture,
    locals: { styles: AppSettings[:picture][:styles].keys.map(&:to_sym).push(:original) }
end