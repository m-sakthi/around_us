class Api::V1::PostsController < ApplicationController
  load_and_authorize_resource except: :create
  
  swagger_controller :posts, "Posts Management"

  swagger_api :index do
    summary 'Lists all Posts'
    param :query, :group_id, :integer, :optional, 'Group ID'
    param :query, :limit, :integer, :optional, 'Number of Posts per page'
    param :query, :page_number, :integer, :optional, 'Page Number'
    response :ok
    response :unauthorized
    response :forbidden
  end

  def index
    @posts = if params[:group_id].present?
      authenticate_group(UsersGroup::Privilege::VIEW, params[:group_id])
      current_user.groups.find(params[:group_id].to_i).posts
    else
      current_user.posts
    end

    limit = params[:limit].to_i > Post::RECORDS_LIMIT ? Post::RECORDS_LIMIT : params[:limit].to_i
    @posts = @posts.order(updated_at: :desc)
      .includes(:pictures, :user, :group, parent: :pictures)
      .page(params[:page_number]).per(limit)
  end

  swagger_api :show do
    summary 'Display a Post\'s details'
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
    notes 'Either body or parent_id is required to create a post'
    param :form, :'post[body]', :string, :optional, 'Body of the post'
    param :form, :'post[group_id]', :integer, :optional, 'Group ID'
    param :form, :'post[parent_id]', :integer, :optional, 'Parent Post''s ID'
    param_list :form, :'post[privacy]', :integer, :optional,
      'Privacy: followers -> 0, friends -> 1, public -> 2', Post::Privacy::ALL
    response :created
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def create
    authenticate_group(UsersGroup::Privilege::CREATE, params[:post][:group_id]) if params[:post][:group_id].present?
    @post = current_user.posts.build(create_params)
    authorize! :create, @post
    if @post.valid?
      @post.save
      render 'show', status: :created
    else
      render_model_errors(@post)
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
    param :form, :'post[body]', :string, :optional, 'Body of the post'
    param :form, :'post[group_id]', :integer, :optional, 'Group ID'
    param_list :form, :'post[privacy]', :integer, :optional,
      'Privacy: followers -> 0, friends -> 1, public -> 2', Post::Privacy::ALL
    response :created
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def update
    @post.update(update_params)
    if @post.errors.present?
      render_model_errors(@post)
    else
      render 'show', status: :created
    end
  end

  private
    def create_params
      params.require(:post).permit(:body, :group_id, :parent_id, :privacy)
    end

    def update_params
      params.require(:post).permit(:body, :group_id, :privacy)
    end

    def authenticate_group(privilege, group_id)
      group = Group.find(group_id)
      raise App::Exception::InsufficientPrivilege.new(_('errors.groups.not_member', id: params[:group_id].to_i)
        ) unless group.can?(current_user.id, privilege)
    end
end
