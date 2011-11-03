require 'rubygems'
require 'twilio-ruby'
require 'Digest'

class HomeController < ApplicationController
  def index
    User.send_daily_email
    account_sid = 'AC0bb1fd0388354f33b14da8ad86289a4f'
    auth_token = '4e443ae95126ba36969b4ca1208d5453'
    @client = Twilio::REST::Client.new account_sid, auth_token
    @messages = @client.account.sms.messages.list
    Rails::logger.debug "Entering home controller index..."
    @messages.each do |message|
      # create each partial post here for all posts not already created
      # also, create a user for all "From" numbers not already assigned to a user
      Rails::logger.debug message.body
      user = User.find(:first, :conditions => ["phone_number = ?",message.from])
      if (user == nil)
        Rails::logger.debug 'Creating new user...'
        user = User.new do |u|
          u.phone_number = message.from
          u.link = Digest::MD5.hexdigest(message.from)
          u.save
        end
        Rails::logger.debug 'Done...'
      end
      
      post = Post.find(:first, :conditions => ["sms_body = ?", message.body])
      if (post == nil)
        Rails::logger.debug 'Creating new post...'
        post = Post.new do |p|
          p.sms_date = message.date_sent
          p.sms_body = message.body
          p.user = user
          p.kind = "p"
          p.completed = false
          p.save
        end
        Rails::logger.debug 'Done...'
      end
    end
    
    # Hack...there may be a better way to do this but whatever
    # Saves posts sent by one of the forms
    if (params[:post] != nil && params[:postid] != nil)
      post = Post.find(params[:postid])
      post.update_attributes(params[:post])
      post.update_completed
    end

    @users = User.find(:all)

    userID = params[:id]
    if userID == nil
      Rails::logger.debug '@userID param is nil'
      redirect_to users_url
      
    else
      Rails::logger.debug '@userID param is ' << userID
      @user = User.find_by_link(params[:id])
      datePosts = params[:date]
      if datePosts == nil
        Rails::logger.debug 'datePosts param is nil'
        dateStrings = @user.posts.map {|post| post.sms_date.strftime('%Y/%m/%d')}.uniq
        @dateLinks = {}
        dateStrings.each {|ds|
          datePosts = getPostsAtDate( @user, ds)
          if datePosts.length > 0
            @dateLinks[ds] = datePosts.all? {|p| p.completed}
          else
            @dateLinks[ds] = false
          end
        }
        @renderPosts = false
      elsif datePosts == 'all'
        @posts = Post.find(:all)
        @renderPosts = true
      else
        Rails::logger.debug 'datePosts param is ' << datePosts
        dateSplit = datePosts.split('/')
        d = DateTime.new(dateSplit[0].to_i,dateSplit[1].to_i,dateSplit[2].to_i)
        Rails::logger.debug d.to_s
        @posts = getPostsAtDate(@user, datePosts)
        @renderPosts = true
      end
    end
  end

  def getPostsAtDate( user, dateStr )
    dateSplit = dateStr.split('/')
    d = DateTime.new(dateSplit[0].to_i,dateSplit[1].to_i,dateSplit[2].to_i)
    Post.find(:all, :conditions => [ "sms_date >= ? AND sms_date < ? AND user_id = ?", d.beginning_of_day, d.tomorrow.beginning_of_day, user.id])
  end
end
