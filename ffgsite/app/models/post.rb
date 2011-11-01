class Post < ActiveRecord::Base
  belongs_to :user
  $p1_prompt = 'Why did you decide not to post this to Facebook?'
  $p2_prompt = 'Were there any people you would especially not want to see this post?'
  $p3_prompt = 'Were there any people you would especially want to see this post?'
  $p4_prompt = 'Where were you when you decided not to post this to Facebook?'
  $p5_prompt = 'What were you doing when you decided not to post this to Facebook?'
  
  $np1_prompt = 'What type of post was it? (e.g. direct message, wall post, picture)'
  $np1_options = ['Direct Message','Wall Post','Picture','Video','Note']
  $np2_prompt = 'Who was the intended audience for the post?'
  $np3_prompt = 'Why did you post it?'
  
  $nn1_prompt = 'Why didn\'t you post anything to Facebook today?'
  $nn2_prompt = 'Why didn\'t you think about posting anything to Facebook today?'
end
