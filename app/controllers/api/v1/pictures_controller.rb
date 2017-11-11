class Api::V1::PicturesController < ApplicationController
	load_and_authorize_resource

  swagger_controller :pictures, "Pictures Management"

  swagger_api :index do
    summary 'Lists all Pictures that user has uploaded'
    # param_list :query, :type, :string, :optional, 'Image for a User or a Post', Picture::ImagableType::ALL
    param :query, :limit, :integer, :optional, 'Number of Posts per page'
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
    param_list :form, :parent_type, :string, :required, 'Image for a User or a Post', Picture::ImagableType::ALL
    param :form, :parent_id, :integer, :required, 'ID of the type'
    param :form, :'picture[image]', :file, :required, 'Image attached for the post'
    param_list :form, :'picture[picture_type]', :string, :required, 'Picture type Profile or Cover if the parent_type is User', Picture::PictureType::ALL
    response :created
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def create
    if params[:parent_type].present? && params[:parent_id].present?
      if params[:parent_type] == Picture::ImagableType::POST && params[:picture][:picture_type].present?
        raise App::Exception::InvalidParameter.new(_('errors.pictures.imageable_type_not_applicable'))
      end
      @user_or_post = params[:parent_type].constantize.find(params[:parent_id])
      @picture = @user_or_post.pictures.new(picture_params)
      if @picture.save
        render 'show', status: :created
      else
        render 'shared/model_errors', locals: { object: @picture }, status: :bad_request
      end
    else
      raise App::Exception::InvalidParameter.new(_('errors.pictures.missing_imageable_type'))
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
      params.require(:picture).permit(:image, :picture_type)
    end
end
