require 'rubygems'
require 'twilio-ruby'
#require 'Digest'

class HomeController < ApplicationController
  #before_filter :updateUsersPosts
  protect_from_forgery :except => :twilioResponse

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
    #response 0 = nothing special, 1 = still need email, 2 = existing user gave us email, 3 = new user signed up correctly
    logger.info 'TwilioResponse entered'

    if (params[:From] != nil)
      logger.info 'From: ' + params[:From] + ';Body: ' + params[:Body]
      user = User.find(:first, :conditions => ["phone_number = ?",params[:From]])
      if (user == nil)
        logger.info 'Creating new user...'
        user = User.new do |u|
          u.phone_number = params[:From]
          u.link = Digest::MD5.hexdigest(params[:From])
          if (params[:Body] =~ /.+@.+\..+/)
            @response = 3
            u.email = params[:Body]
          else
            @response = 4
          end
          u.doneparticipating = DateTime.now + 8
          u.save
        end
        
        # send them email copy of instructions
        UserMailer.deliver_instructions_copy(user)

        if @response == 4 #need to also create a post
          createPost(DateTime.now, params[:Body], user, "p", false)
        end
        logger.info 'Done creating new user'
      else
        if user.email == nil || user.email == ''
          if (params[:Body] =~ /.+@.+\..+/)
            user.email = params[:Body]
            user.save
            @response = 2
          else
            createPost(DateTime.now, params[:Body], user, "p", false)
            @response = 1
          end
        else
          createPost(DateTime.now, params[:Body], user, "p", false)
          @response = 0
        end
      end
    else
      @response = 0
      logger.info 'Accessing Twilio Response incorrectly'
    end
    
    if @response == 4
      render :xml => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Sms>Welcome to the Facebook Friend Grouping study! It seems that you didn't send us your email. Please respond with just your email address (e.g. bovik@cmu.edu)</Sms></Response>"
    elsif @response == 3
      render :xml => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Sms>Welcome to the Facebook Friend Grouping study! We will send you nightly reminders at this email address to complete a short survey for the duration of the study.</Sms></Response>"
    elsif @response == 2
      render :xml => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Sms>Thanks for giving us your e-mail address! We will send you nightly reminders at this address to complete a short survey for the duration of the study.</Sms></Response>"
    elsif @response == 1
      render :xml => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response><Sms>Thanks for the post! But we still need your e-mail address. Please respond to us with just your email (e.g. bovik@cmu.edu)</Sms></Response>"
    elsif @response == 0
      render :xml => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Response></Response>"
    end
  end

  protected
  
  def createPost(date, body, user, kind, completed)
    logger.info 'Creating new post...'
    post = Post.new do |p|
      p.sms_date = date
      p.sms_body = body
      p.user = user
      p.kind = kind
      p.completed = completed
      p.save
    end
    logger.info 'Done creating new post'
  end

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
