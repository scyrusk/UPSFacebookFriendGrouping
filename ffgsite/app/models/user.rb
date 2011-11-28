class User < ActiveRecord::Base
  has_many :posts
  
  def self.send_daily_email
    logger.info 'Getting into send daily mail'
    for user in User.all
      yesterday = DateTime.now 
      if(user.email != nil && user.doneparticipating != nil && user.doneparticipating > yesterday)
	logger.info 'Passed conditional for send daily mail'
        UserMailer.deliver_fill_in_survey(user, yesterday)
      end
    end
  end
  
  def getPostsAtDate( dateStr )
    dateSplit = dateStr.split('/')
    d = DateTime.new(dateSplit[0].to_i,dateSplit[1].to_i,dateSplit[2].to_i)
    Post.find(:all, :conditions => [ "sms_date >= ? AND sms_date < ? AND user_id = ?", d.beginning_of_day, d.tomorrow.beginning_of_day, self.id])
  end

  def getToPostAtDate( dateStr )
    dateSplit = dateStr.split('/')
    d = DateTime.new(dateSplit[0].to_i,dateSplit[1].to_i,dateSplit[2].to_i)
    Post.find(:all, :conditions => [ "post_date >= ? AND post_date <= ? AND user_id = ?", d.beginning_of_day, d.tomorrow.beginning_of_day, self.id])
  end

  def completedQuestionnaireAt( date )
    posts = Post.find(:all, :conditions => [ "post_date >= ? AND post_date < ? AND user_id = ?", date.beginning_of_day, date.tomorrow.beginning_of_day, self.id])
    return posts.length > 0 && posts.all?{|p| p.completed}
  end

  def getPostsByDateMap
    @postsByDate = {}
    dateStrings = self.posts.map { |p| p.post_date.strftime('%Y/%m/%d')}.uniq
    dateStrings.sort! { |a,b| a <=> b }
    dateStrings.each do |ds|
       @postsByDate[ds] = self.getToPostAtDate(ds)
    end
    return @postsByDate
  end
end
