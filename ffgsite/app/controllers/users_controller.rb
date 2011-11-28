class UsersController < ApplicationController
  before_filter :authenticate
  def index
    @users = User.all
    @userMap = {}
    @users.each do |u|
      numTotal = 0
      numCompleted = 0
      dateStrings = u.posts.map { |p| p.post_date.strftime('%Y/%m/%d')}.uniq
      dateStrings.sort! { |a,b| a <=> b }
      dateStrings.each do |ds|
        datePosts = u.getToPostAtDate(ds)
        if (datePosts.length > 0 && datePosts.all? {|p| p.completed})
          numCompleted += 1
        end
        numTotal += 1
      end
      @userMap[u] = {:numComp => numCompleted, :numTot => numTotal } 
    end
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
  
  protected
end
