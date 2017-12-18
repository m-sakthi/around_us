object @user

@user ||= locals[:object]

attributes :id, :email, :user_name, :first_name, :last_name

profile = @user.pictures.profile.first
node(:profile, if: profile.present? ) do
  partial 'pictures/style', object: profile,
    locals: { styles: [:small, :medium] }
end