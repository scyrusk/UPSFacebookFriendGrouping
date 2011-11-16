require 'rubygems'
require 'twilio-ruby'
#require 'Digest'

class HomeController < ApplicationController
  #before_filter :updateUsersPosts

  def index
    # Hack...there may be a better way to do this but whatever
    # Saves posts sent by one of the forms
    if (params[:post] != nil && params[:postid] != nil)
      post = Post.find(params[:postid])
      post.update_attributes(params[:post])
      Rails::logger.debug 'Update post parameter:' << params[:post][:sms_body].to_s << ''
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
        dateStrings.sort! { |a,b| a <=> b }
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
        if(@posts.length == 0 )
          redirect_to  home_path << "/forgot_posts?id=" << @user.link << ";date=" << params[:date], :method => "get"
        end
        @renderPosts = true
      end
    end
  end
  
  def forgot_posts
    @user = User.find_by_link(params[:id])
    datePosts = params[:date]
  end
  
  def posted_on_fb
    @user = User.find_by_link(params[:id])
    datePosts = params[:date]
  end


  def twilioResponse
    logger.info 'TwilioResponse entered'

    if (params[:From] != nil)
      logger.info 'From: ' + params[:From] + ';Body: ' + params[:Body]
      user = User.find(:first, :conditions => ["phone_number = ?",params[:From]])
      if (user == nil)
        logger.info 'Creating new user...'
        user = User.new do |u|
          u.phone_number = params[:From]
          u.link = Digest::MD5.hexdigest(params[:From])
          u.email = params[:Body]
          u.doneparticipating = DateTime.now + (3600 * 24 * 8)
          u.save
        end
        logger.info 'Done creating new user'
      else
        logger.info 'Creating new post...'
        post = Post.new do |p|
          p.sms_date = DateTime.now
          p.sms_body = params[:Body]
          p.user = user
          p.kind = "p"
          p.completed = false
          p.save
        end
        logger.info 'Done creating new post'
      end
    else
      logger.info 'Accessing Twilio Response incorrectly'
    end
  end

  protected

  def updateUsersPosts
    account_sid = 'AC0bb1fd0388354f33b14da8ad86289a4f'
    auth_token = '4e443ae95126ba36969b4ca1208d5453'
    @client = Twilio::REST::Client.new account_sid, auth_token
    @messages = @client.account.sms.messages.list
    @messages.sort! { |a,b| Date.strptime(a.date_sent,'%a, %d %b %Y %H:%M:%S %z') <=> Date.strptime(b.date_sent,'%a, %d %b %Y %H:%M:%S %z') }
    Rails::logger.debug "Entering home controller index..."
    @messages.each do |message|
      # create each partial post here for all posts not already created
      # also, create a user for all "From" numbers not already assigned to a user
      Rails::logger.debug 'Message date: ' << message.date_sent
      user = User.find(:first, :conditions => ["phone_number = ?",message.from])
      if (user == nil)
        Rails::logger.debug 'Creating new user...'
        user = User.new do |u|
          u.phone_number = message.from
          u.link = Digest::MD5.hexdigest(message.from)
          u.email = message.body
          u.doneparticipating = DateTime.now + 8
          u.save
        end
        Rails::logger.debug 'Done...'
      else # because first text message should have e-mail as body
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
    end
  end
  
  def getPostsAtDate( user, dateStr )
    dateSplit = dateStr.split('/')
    d = DateTime.new(dateSplit[0].to_i,dateSplit[1].to_i,dateSplit[2].to_i)
    Post.find(:all, :conditions => [ "sms_date >= ? AND sms_date < ? AND user_id = ?", d.beginning_of_day, d.tomorrow.beginning_of_day, user.id])
  end
end
