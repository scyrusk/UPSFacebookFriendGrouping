class AddIsParticipatingToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.datetime :doneparticipating
    end
  end

  def self.down
    remove_column :users, :doneparticipating
  end
end
