require 'rubygems'
require 'twilio-ruby'
require 'Digest'

class HomeController < ApplicationController
  def index
    UserMailer.deliver_hithere
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
          p.save
        end
        Rails::logger.debug 'Done...'
      end
    end

    @users = User.find(:all)
    if (@users == nil)
      Rails::logger.debug '@users is nil for some reason'
    else
      Rails::logger.debug '@users isn\'t nil in the controller'
    end
    @posts = Post.find(:all)
    if (@posts == nil)
      Rails::logger.debug '@posts is nil for some reason'
    else
      Rails::logger.debug '@posts isn\'t nil in the controller'
    end

    userID = params[:id]
    if userID == nil
      Rails::logger.debug '@userID param is nil'
    else
      Rails::logger.debug '@userID param is ' << userID
      @user = User.find_by_link(params[:id])
    end

  end
end
