class Post < ActiveRecord::Base
  attr_accessible :sms_body,:p1,:p2,:p3,:p4,:p5,:np1,:np2,:np3,:nn1,:nn2,:long_description,:post_date
  belongs_to :user
  
  def update_completed
    if (self.kind.casecmp("p") == 0 && meaningful_p ) || (self.kind.casecmp("np") && self.meaningful_np) || (self.kind.casecmp("nn") && self.meaningful_nn)
      self.completed = true
    else
      self.completed = false
    end
    self.save
  end

  def meaningful( val )
    val != nil && val.casecmp("") != 0
  end
  
  def meaningful_p
    (meaningful(self.p1) && meaningful(self.p2) && meaningful(self.p3) && meaningful(self.p4) && meaningful(self.p5) && meaningful(self.long_description))
  end

  def meaningful_np
    (meaningful(self.np1) && meaningful(self.np2) && meaningful(self.np3))
  end

  def meaningful_nn
    (meaningful(self.nn1) && meaningful(self.nn2))
  end
  
  def completed_text
    if completed 
      'Completed' 
    else 
      'Not Completed' 
    end
  end
  
  def edit_link_text
    if completed 
      'Update' 
    else 
      'Answer Questionnaire' 
    end
  end
end
