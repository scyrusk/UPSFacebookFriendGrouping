class AddKindToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :kind, :string
  end

  def self.down
    remove_column :posts, :kind
  end
end
