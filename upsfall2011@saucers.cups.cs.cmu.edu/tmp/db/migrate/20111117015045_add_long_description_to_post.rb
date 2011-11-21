class AddLongDescriptionToPost < ActiveRecord::Migration
  def self.up
    change_table :posts do |t|
      t.text :long_description
    end
  end

  def self.down
    remove_column :posts, :long_description
  end
end