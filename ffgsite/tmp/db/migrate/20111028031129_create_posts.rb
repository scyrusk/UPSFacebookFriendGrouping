class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :user_id
      t.datetime :sms_date
      t.text :sms_body
      t.text :p1
      t.text :p2
      t.text :p3
      t.text :p4
      t.text :p5
      t.string :np1
      t.text :np2
      t.text :np3
      t.text :nn1
      t.text :nn2

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
