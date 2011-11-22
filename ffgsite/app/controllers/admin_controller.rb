class AdminController < ApplicationController
  before_filter :authenticate
  
  def index
    @users = User.all
    @userMap = {}
    @users.each do |u|
      numTotal = 0
      numCompleted = 0
      # calculate user statistics
      dateStrings = u.posts.map { |p| p.sms_date.strftime('$Y/%m/%d') }.uniq
      dateStrings.sort! { |a,b| a <=> b }
      dateStrings.each do |ds|
        datePosts = u.getPostsAtDate(ds)
        if (datePosts.length > 0 && datePosts.all? {|p| p.completed})
          numCompleted += 1
        end
        numTotal += 1
      end
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

  protected
  
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "admin" && password == "lorrieisawesome"
    end
  end
  
  protected
end
