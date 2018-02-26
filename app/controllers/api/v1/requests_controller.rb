class Api::V1::RequestsController < ApplicationController
  authorize_resource
  before_action :validate_params, only: [:index, :create, :edit]
  swagger_controller :requests, "Requests Management"

  swagger_api :index do
    summary 'Lists all the Pending Friend Requests for Current User'
    param_list :query, :status, :string, :optional, 'Status. default -> fresh', Request::Status::ALL
    param :query, :limit, :integer, :optional, 'Number of Groups per page'
    param :query, :page_number, :integer, :optional, 'Page Number'
    response :ok
    response :bad_request
    response :unauthorized
    response :forbidden
  end

  def index
    @requests = current_user.pending_requests.where(status: params[:status] || Request::Status::FRESH)
  end

  swagger_api :create do
    summary 'Creates a Friend Request'
    param :form, :friend_id, :string, :optional, 'Friend User\'s ID'
    response :created
    response :bad_request
    response :unauthorized
    response :forbidden
  end

  def create
    @request = current_user.requests.fresh.build(friend_id: params[:friend_id])
    if @request.valid?
      @request.save
      head :created
    else
      render_model_errors(@request)
    end
  end

  swagger_api :edit do
    summary 'Edits a Request'
    param :form, :friend_id, :integer, :required, 'Friend User ID'
    param_list :form, :status, :string, :optional, 'Status', [Request::Status::ACCEPTED, Request::Status::DECLINED]
    response :ok
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def edit
    @request = current_user.pending_requests.find_by_user_id!(params[:friend_id])
    @request.update(status: params[:status])
    if @request.errors.present?
      render_model_errors(@request)
    else
      head :ok
    end
  end  

  swagger_api :delete do
    summary 'Deletes a Request'
    param :query, :friend_id, :integer, :required, 'Friend User ID'
    response :ok
    response :bad_request
    response :forbidden
    response :unauthorized
  end

  def delete
    @request = current_user.requests.find_by_friend_id!(params[:friend_id])
    @request.destroy
    head :ok
  end

  private
    def validate_params
      raise App::Exception::InvalidParameter.new(_('errors.invalid_param_values', param_name: 'status',
        valid_values: Relationship::Status::ALL.join(", "))
      ) unless params[:status].blank? || params[:status].in?(Request::Status::ALL)
    end
end
