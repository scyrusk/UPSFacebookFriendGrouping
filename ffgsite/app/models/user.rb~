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
  
  def getPostsAtDate( dateStr )
    dateSplit = dateStr.split('/')
    d = DateTime.new(dateSplit[0].to_i,dateSplit[1].to_i,dateSplit[2].to_i)
    Post.find(:all, :conditions => [ "sms_date >= ? AND sms_date < ? AND user_id = ?", d.beginning_of_day, d.tomorrow.beginning_of_day, self.id])
  end
end
