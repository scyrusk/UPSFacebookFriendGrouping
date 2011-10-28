class Post < ActiveRecord::Base
  belongs_to :user
  def self.p1_prompt = 'Why did you decide not to post this to Facebook?' end
  def self.p2_prompt = 'Were there any people you would especially not want to see this post?' end
  def self.p3_prompt = 'Were there any people you would especially want to see this post?' end
  def self.p4_prompt = 'Where were you when you decided not to post this to Facebook?' end
  def self.p5_prompt = 'What were you doing when you decided not to post this to Facebook?' end
  
  def self.np1_prompt = 'What type of post was it? (e.g. direct message, wall post, picture)' end
  def self.np1_options = ['Direct Message','Wall Post','Picture','Video','Note'] end
  def self.np2_prompt = 'Who was the intended audience for the post?' end
  def self.np3_prompt = 'Why did you post it?' end
  
  def self.nn1_prompt = 'Why didn\'t you post anything to Facebook today?' end
  def self.nn2_prompt = 'Why didn\'t you think about posting anything to Facebook today?' end
end
