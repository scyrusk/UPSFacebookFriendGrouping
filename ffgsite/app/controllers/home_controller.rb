require 'rubygems'
require 'twilio-ruby'

class HomeController < ApplicationController
  def index
    account_sid = 'AC0bb1fd0388354f33b14da8ad86289a4f'
    auth_token = '4e443ae95126ba36969b4ca1208d5453'
    @client = Twilio::REST::Client.new account_sid, auth_token
    @messages = @client.account.sms.messages.list
    @messages.each do |message|
      puts message.inspect
    end
  end
end
