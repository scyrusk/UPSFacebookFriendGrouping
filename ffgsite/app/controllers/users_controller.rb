class UsersController < ApplicationController
  before_filter :authenticate
  def index
    @users = User.all
  end

  def show
    @user = User.find_by_link(params[:id])
  end

  def new
    @user = User.new
  end

  def create
   @user = User.find(params[:id])
    if @user.save
      redirect_to users_url
    else
      render :action => "new"
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to users_url
    else
      render :action => "edit"
    end
  end
  
  protected
  
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "admin" && password == "lorrieisawesome"
    end
  end

end
