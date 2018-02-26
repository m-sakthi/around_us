class Api::V1::RelationshipsController < ApplicationController
  authorize_resource
  swagger_controller :relationships, "Relationships Management"

  swagger_api :index do
    summary 'Lists all the Relationships'
    notes 'Lists the current user\'s friends'
    param :query, :user_id, :ingeter, :optional, 'User ID'
    param :query, :type, :string, :optional, 'Type: can be followers, following, friends'
    param :query, :limit, :integer, :optional, 'Number of Groups per page'
    param :query, :page_number, :integer, :optional, 'Page Number'
    response :ok
    response :bad_request
    response :unauthorized
    response :forbidden
  end

  def index
    validate_params
    user = params[:user_id].present? ?
      User.find(params[:user_id]) : current_user
    
    @users = user.send(params[:type])
    limit = params[:limit].to_i > User::Settings::RECORDS_LIMIT ? User::Settings::RECORDS_LIMIT : params[:limit].to_i
    @users = @users.page(params[:page_number]).per(limit)

    render 'api/v1/users/index', status: :ok
  end

  swagger_api :follow do
    summary 'Follow a user'
    param :form, :user_id, :integer, :required, 'user_id of a user to follow'
    response :created
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def follow
    @relationship = current_user.relationships.follower.build(follower_id: params[:user_id])
    if @relationship.valid?
      @relationship.save
      authorize! :follow, @relationship
      head :created
    else
      render_model_errors(@relationship)
    end
  end

  swagger_api :unfollow do
    summary 'Unfollow a user following user'
    param :form, :user_id, :integer, :required, 'user_id of user to unfollow'
    response :created
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def unfollow
    current_user.relationships.follower.find_by_follower_id!(params[:user_id]).destroy
    head :ok
  end

  swagger_api :unfriend do
    summary 'Unfriend a user following user'
    param :form, :user_id, :integer, :required, 'user_id of user to unfriend'
    response :created
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def unfriend
    relationship = current_user.friendships.find_by_follower_id!(params[:user_id])
    relationship.destroy_reverse_friendship
    relationship.destroy
    head :ok
  end

  private
    def validate_params
      raise App::Exception::InvalidParameter.new(_('errors.required_param_missing', name: "type")
      ) if params[:type].blank?

      raise App::Exception::InvalidParameter.new(_('errors.invalid_param_values', param_name: 'type', valid_values: "followers, friends, following")
      ) unless params[:type].in?(%w(followers friends following))
    end
end
