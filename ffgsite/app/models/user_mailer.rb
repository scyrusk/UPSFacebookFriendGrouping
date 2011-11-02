class UserMailer < ActionMailer::Base
  def fill_in_survey(user)
    recipients  user.email
    from        "hcistudy@cs.cmu.edu"
    subject     "Diary study nightly survey"
    body        :user => user
  end
  
  def hithere
    recipients  "wiese@cmu.edu"
    from        "hcistudy@cs.cmu.edu"
    subject     "Diary study nightly survey"
    body        "Hiya"
  end
end
