class Api::V1::PicturesController < ApplicationController
	load_and_authorize_resource except: :create

  swagger_controller :pictures, "Pictures Management"

  swagger_api :index do
    summary 'Lists all Pictures that user has uploaded'
    # param_list :query, :type, :string, :optional, 'Image for a User or a Post', Picture::ImagableType::ALL
    param :query, :limit, :integer, :optional, 'Number of Pictures per page'
    param :query, :page_number, :integer, :optional, 'Page Number'
    response :ok
    response :unauthorized
    response :forbidden
  end

  def index
    @pictures = current_user.get_pictures
  end

  swagger_api :create do
    summary 'Create new Picture'
    param_list :form, :'picture[imageable_type]', :string, :required, 'Image for a User or a Post', Picture::ImagableType::ALL
    param :form, :'picture[imageable_id]', :integer, :required, 'ID of the type'
    param :form, :'picture[image]', :file, :required, 'Image attached for the post'
    param_list :form, :'picture[picture_type]', :string, :required, 'Picture type Profile or Cover if the parent_type is User', Picture::PictureType::ALL
    response :created
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def create
    validate_params
    @picture = Picture.new(picture_params)
    authorize! :create, @picture
    if @picture.valid?
      @picture.save
      render 'show', status: :created
    else
      render_model_errors(@picture)
    end
  end

  swagger_api :destroy do
    summary "Destroy a Picture"
    param :path, :id, :integer, :required, 'Picture ID'
    response :ok
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def destroy
    @picture.delete
    head :ok
  end

  swagger_api :show do
    summary 'Display a Picture\'s details'
    param :path, :id, :integer, :required, 'Picture ID'
    response :ok
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def show
  end

  private
    def picture_params
      params.require(:picture).permit(:image, :picture_type, :imageable_type, :imageable_id)
    end

    def validate_params
      if params.present? && params[:picture].present?
        raise App::Exception::InvalidParameter.new(_('errors.pictures.invalid_imageable_type', types: Picture::ImagableType::ALL.join("/") )
          ) if params[:picture][:imageable_type].blank? || Picture::ImagableType::ALL.exclude?(params[:picture][:imageable_type])
        raise App::Exception::InvalidParameter.new(_('errors.pictures.invalid_picture_type')
          ) if params[:picture][:picture_type].present? && Picture::PictureType::ALL.exclude?(params[:picture][:picture_type])
      end
    end
end
