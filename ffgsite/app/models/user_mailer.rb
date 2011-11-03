class UserMailer < ActionMailer::Base
  def fill_in_survey(user, yesterday)
    recipients  user.email
    from        "hcistudy@cs.cmu.edu"
    subject     "Diary study nightly survey"
    body        :user => user, :yesterday => yesterday
    content_type  "text/html"
  end
end
