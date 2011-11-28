class AddPostDateToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :post_date, :date
  end

  def self.down
    remove_column :posts, :post_date
  end
end
