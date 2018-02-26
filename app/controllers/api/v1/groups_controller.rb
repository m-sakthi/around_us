class Api::V1::GroupsController < ApplicationController
  load_and_authorize_resource except: [:create, :add_members, :remove_members]
  load_resource only: [:add_members, :remove_members]

  before_action :validate_privilege, only: [:add_members, :update_privilege]

  swagger_controller :groups, "Groups Management"

  swagger_api :index do
    summary 'Lists all Groups that user is a part of'
    param :query, :status, :integer, :optional,
      'Default: Public & Private ,0 -> Archived, 1 -> Private, 2 -> Public'
    param :query, :limit, :integer, :optional, 'Number of Groups per page'
    param :query, :page_number, :integer, :optional, 'Page Number'
    response :ok
    response :unauthorized
    response :forbidden
  end

  def index
    @groups = current_user.groups.order(:created_at).includes(:creator, :users_groups)
    if params[:status].present?
      status = params[:status].to_i
      @groups = @groups.where(visibility: status) if status.in?(Group::Visibility::ALL)
    end
    limit = params[:limit].to_i > Group::RECORDS_LIMIT ? Group::RECORDS_LIMIT : params[:limit].to_i
    @groups = @groups.page(params[:page_number]).per(limit)
  end

  swagger_api :create do
    summary 'Create a new group'
    param :form, :'group[name]', :string, :required, 'Group Name'
    param :form, :'group[purpose]', :string, :optional, 'Purpose of the Group'
    param_list :form, :'group[visibility]', :string, :optional,
      'Visibility: Default: Public, 1 -> Private, 2 -> Public', [Group::Visibility::PRIVATE, Group::Visibility::PUBLIC]
    response :created
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def create
    @group = current_user.created_groups.build(group_params)
    authorize! :create, @group
    if @group.save
      render :show, status: :created
    else
      render_model_errors(@group)
    end
  end

  swagger_api :update do
    summary 'Update a Group'
    param :path, :id, :integer, :required, 'Group ID'
    param :form, :'group[name]', :string, :optional, 'Group Name'
    param :form, :'group[purpose]', :string, :optional, 'Purpose of the Group'
    param_list :form, :'group[visibility]', :string, :optional,
      'Visibility: Default: Public, 0 -> Archived, 1 -> Private, 2 -> Public', Group::Visibility::ALL
    response :created
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def update
    @group.update(group_params)
    if @group.errors.present?
      render_model_errors(@group)
    else
      render :show, status: :ok
    end
  end

  swagger_api :add_members do
    summary 'Adds users to group'
    notes 'Adds list of users with given privilege or current user(when user_ids is blank) with view privilege'
    param :path, :id, :integer, :required, 'Group ID'
    param :form, :user_ids, :string, :optional, 'Comma separated string of user_ids'
    param_list :form, :privilege, :string, :optional,
      'Privileges: can_view -> 0 (default), can_comment -> 1, can_create -> 2, admin -> 3',
      UsersGroup.privileges.values
    response :ok
    response :bad_request
    response :unauthorized
    response :forbidden
  end

  def add_members
    if params[:user_ids].blank?
      raise App::Exception::InsufficientPrivilege.new(_('errors.groups.cannot_join_unless_public_group')
        ) unless @group.visibility == Group::Visibility::PUBLIC
      @group.add_user(current_user.id)
    else
      authorize! :add_members, @group
      @group.add_multiple_users(sanitized_users_ids, params[:privilege])
    end

    if @group.errors.present?
      render_model_errors(@group)
    else
      @users_groups = @group.users_groups
      render :members, status: :created
    end
  end

  swagger_api :remove_members do
    summary 'Remove users from the group'
    notes 'Removes list of users or current user(when user_ids is blank) from the group'
    param :path, :id, :integer, :required, 'Group ID'
    param :form, :user_ids, :string, :optional, 'Comma separated string of user_ids'
    response :ok
    response :unauthorized
    response :forbidden
  end

  def remove_members
    if params[:user_ids].blank?
      @group.remove_users(current_user.id)
    else
      authorize! :remove_members, @group
      @group.remove_users(sanitized_users_ids)
    end
    head :ok
  end

  swagger_api :update_privilege do
    summary 'Updates the privilege of the given user.'
    notes 'All the member of group has minimum of can_view access'
    param :path, :id, :integer, :required, 'Group ID'
    param :form, :user_id, :string, :required, 'User ID'
    param_list :form, :privilege, :string, :optional,
      'Privileges: can_view -> 0 (default), can_comment -> 1, can_create -> 2, admin -> 3',
      UsersGroup.privileges.values
    response :ok
    response :bad_request
    response :unauthorized
    response :forbidden
  end

  def update_privilege
    raise App::Exception::InvalidParameter.new(_('errors.required_param_missing', name: "user_ids")
      ) if params[:user_id].blank? || params[:id].blank?

    user_id = params[:user_id].to_i
    raise App::Exception::InvalidParameter.new(_('errors.groups.cannot_update_self_privilege')
      ) if user_id == current_user.id

    users_group = @group.users_groups.find_by_user_id!(user_id)
    users_group.update(privilege: params[:privilege].to_i)
    head :ok
  end

  swagger_api :members do
    summary 'List all the members of the group'
    notes 'Lists all the member of group with the given privilege'
    param :path, :id, :integer, :required, 'Group ID'
    param_list :query, :privilege, :string, :optional,
      'Privileges: default -> all, can_view -> 0, can_comment -> 1, can_create -> 2, admin -> 3',
      UsersGroup.privileges.values
    response :ok
    response :bad_request
    response :unauthorized
    response :forbidden
  end

  def members
    @users_groups = @group.users_groups.includes(:user)
  end

  swagger_api :show do
    summary 'Display a Group\'s details'
    param :path, :id, :integer, :required, 'Group ID'
    response :ok
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def show
  end

  swagger_api :destroy do
    summary 'Destroy a group'
    param :path, :id, :integer, :required, 'Group ID'
    response :ok
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def destroy
    @group.destroy
    head :ok
  end

  private
    def group_params
      params.require(:group).permit(:name, :purpose, :visibility)
    end

    def validate_privilege
      raise App::Exception::InvalidParameter.new(_('errors.invalid_param_values',
        param_name: 'privilege', valid_values: UsersGroup.privileges.values.join(", "))
      ) unless params[:privilege].to_i.in?(UsersGroup.privileges.values)
    end

    def sanitized_users_ids
      params[:user_ids].to_s.split(",").map(&:strip).map(&:to_i).reject{ |i| i.in?([0, current_user.id]) }
    end
end
