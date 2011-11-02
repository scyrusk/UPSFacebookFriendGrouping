# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111102011826) do

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.datetime "sms_date"
    t.text     "sms_body"
    t.text     "p1"
    t.text     "p2"
    t.text     "p3"
    t.text     "p4"
    t.text     "p5"
    t.string   "np1"
    t.text     "np2"
    t.text     "np3"
    t.text     "nn1"
    t.text     "nn2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "completed"
    t.string   "kind"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "phone_number"
    t.string   "link"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
