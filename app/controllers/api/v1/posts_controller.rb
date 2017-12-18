class Api::V1::PostsController < ApplicationController
  load_and_authorize_resource
  
  swagger_controller :posts, "Posts Management"

  swagger_api :index do
    summary 'Lists all Posts'
    param :query, :limit, :integer, :optional, 'Number of Posts per page'
    param :query, :page_number, :integer, :optional, 'Page Number'
    response :ok
    response :unauthorized
    response :forbidden
  end

  def index
    @posts = current_user.posts.includes(:pictures)
      .page(params[:page_number]).per(params[:limit])
  end

  swagger_api :show do
    summary 'Display a Posts details'
    param :path, :id, :integer, :required, 'Post ID'
    response :ok
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def show
  end

  swagger_api :create do
    summary 'Create new Post'
    param :form, :'post[body]', :string, :required, 'Body of the post'
    response :created
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def create
    @post.user_id = current_user.id
    if @post.save
      render 'show', status: :created
    else
      render 'shared/model_errors', locals: { object: @post }, status: :bad_request
    end
  end

  swagger_api :destroy do
    summary "Destroy a post"
    param :path, :id, :integer, :required, 'Post ID'
    response :ok
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def destroy
    @post.delete
    head :ok
  end

  swagger_api :update do
    summary 'Update a Post'
    param :path, :id, :integer, :required, 'Post ID'
    param :form, :'post[body]', :string, :required, 'Body of the post'
    response :created
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def update
    @post.update(post_params)
    if @post.errors.present?
      render 'shared/model_errors', locals: { object: @post }, status: :bad_request
    else
      render 'show', status: :created
    end
  end

  private
    def post_params
      params.require(:post).permit(:body)
    end
end
