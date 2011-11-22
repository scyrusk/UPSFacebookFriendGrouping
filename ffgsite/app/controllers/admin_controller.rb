class AdminController < ApplicationController
  before_filter :authenticate
  
  def index
    @users = User.all
    @userMap = {}
    @users.each do |u|
      numTotal = 0
      numCompleted = 0
      postsByDate = u.getPostsByDateMap
      postsByDate.each do |k,v|
        if (v.length > 0 && v.all? {|p| p.completed})
          numCompleted += 1
        end
        numTotal +=1
      end
      # calculate user statistics
      @userMap[u] = {:numComp => numCompleted, :numTot => numTotal, :done => DateTime.now > u.doneparticipating, :qualified => numCompleted >= 4}
    end
  end

  def user
    @user = User.find_by_link(params[:id])
    if @user != nil
      @postsByDate = @user.getPostsByDateMap
    end
  end

  def post
    @post = Post.find_by_id(params[:postid])
    @userid = params[:id]
  end
  
  def allPosts
    @user = User.find_by_link(params[:id])
    if @user != nil
      @postsByDate = @user.getPostsByDateMap
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
