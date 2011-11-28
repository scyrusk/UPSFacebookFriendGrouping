class AddPostDateToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :post_date, :date

    Post.all.each {|p| p.update_attributes!(:post_date => p.sms_date)}
  end

  def self.down
    remove_column :posts, :post_date
  end
end
