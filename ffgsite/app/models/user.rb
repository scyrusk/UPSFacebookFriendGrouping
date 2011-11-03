class User < ActiveRecord::Base
  has_many :posts
  
  def self.send_daily_email
    for user in User.all
      yesterday = Time.now - 3600 # an hour ago it was yesterday
      if(user.email != nil && user.doneparticipating != nil && user.doneparticipating > yesterday)
        UserMailer.deliver_fill_in_survey(user, yesterday)
      end
    end
  end
  
end
