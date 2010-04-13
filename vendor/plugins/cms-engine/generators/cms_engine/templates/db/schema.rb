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

ActiveRecord::Schema.define(:version => 20091217135521) do

  create_table "acts_as_xapian_jobs", :force => true do |t|
    t.string  "model",    :null => false
    t.integer "model_id", :null => false
    t.string  "action",   :null => false
  end

  add_index "acts_as_xapian_jobs", ["model", "model_id"], :name => "index_acts_as_xapian_jobs_on_model_and_model_id", :unique => true

  create_table "attachments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page_id"
    t.integer  "attachable_id"
    t.integer  "position"
    t.string   "attachable_type"
    t.string   "container"
    t.string   "size"
  end

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.boolean  "approved",                       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",            :limit => 50, :default => ""
    t.string   "name"
    t.string   "email"
    t.text     "comment"
    t.string   "ip"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "enquiries", :force => true do |t|
    t.datetime "created_at"
    t.boolean  "newsletter",                 :default => false
    t.string   "source"
    t.string   "name"
    t.string   "role"
    t.string   "company"
    t.string   "email"
    t.string   "telephone"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "county"
    t.string   "postcode"
    t.string   "prefered_method_of_contact"
    t.text     "message"
    t.string   "gender"
    t.integer  "age"
    t.string   "referal"
  end

  create_table "file_upload_versions", :force => true do |t|
    t.integer  "file_upload_id"
    t.integer  "user_id"
    t.integer  "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version_comment"
    t.string   "title"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.string   "tag_list"
  end

  create_table "file_uploads", :force => true do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.string   "title"
    t.datetime "created_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "updated_at"
    t.integer  "version"
    t.string   "tag_cache"
  end

  create_table "image_versions", :force => true do |t|
    t.integer  "image_id"
    t.integer  "user_id"
    t.integer  "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version_comment"
    t.string   "title"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.float    "resize"
    t.integer  "crop_w"
    t.integer  "crop_h"
    t.integer  "crop_x"
    t.integer  "crop_y"
    t.string   "tag_list"
  end

  create_table "images", :force => true do |t|
    t.datetime "created_at"
    t.string   "title"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.float    "resize",            :default => 1.0
    t.integer  "crop_w"
    t.integer  "crop_h"
    t.integer  "crop_x"
    t.integer  "crop_y"
    t.integer  "version"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "updated_at"
    t.string   "tag_cache"
  end

  create_table "page_version_attachments", :force => true do |t|
    t.integer "page_version_id"
    t.integer "attachable_id"
    t.integer "position"
    t.string  "attachable_type"
    t.string  "container"
    t.string  "size"
  end

  create_table "page_versions", :force => true do |t|
    t.integer  "page_id"
    t.integer  "user_id"
    t.integer  "version"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version_comment"
    t.datetime "publish_from"
    t.datetime "publish_to"
    t.string   "title"
    t.string   "meta_title"
    t.string   "meta_description"
    t.string   "meta_keywords"
    t.string   "nav_title"
    t.string   "url"
    t.text     "intro"
    t.text     "body"
    t.string   "tag_list"
  end

  create_table "pages", :force => true do |t|
    t.integer  "position"
    t.integer  "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "title"
    t.string   "meta_title"
    t.string   "meta_description"
    t.string   "meta_keywords"
    t.string   "nav_title"
    t.string   "slug"
    t.string   "slug_path"
    t.string   "title_path"
    t.boolean  "locked",              :default => false, :null => false
    t.string   "url"
    t.text     "intro"
    t.text     "body"
    t.integer  "creator_user_id"
    t.string   "state"
    t.datetime "publish_from"
    t.datetime "publish_to"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "tag_cache"
    t.boolean  "visible",             :default => false
    t.integer  "top_level_page_id"
    t.boolean  "show_comments",       :default => true
    t.boolean  "allow_new_comments",  :default => true
    t.string   "ancestry"
    t.boolean  "children_restricted", :default => false
  end

  add_index "pages", ["ancestry"], :name => "index_pages_on_ancestry"

  create_table "publishable_events", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "assigned_user_id"
    t.integer  "publishable_id"
    t.string   "publishable_type"
    t.string   "comment"
    t.string   "from_state"
    t.string   "to_state"
    t.string   "event_name"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
    t.string "description"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
    t.integer "user_id"
  end

  add_index "taggings", ["tag_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_type"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"
  add_index "taggings", ["user_id", "tag_id", "taggable_type"], :name => "index_taggings_on_user_id_and_tag_id_and_taggable_type"
  add_index "taggings", ["user_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_user_id_and_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0, :null => false
    t.string  "permalink"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"
  add_index "tags", ["taggings_count"], :name => "index_tags_on_taggings_count"

  create_table "user_page_permissions", :force => true do |t|
    t.integer "user_id"
    t.integer "page_id"
    t.boolean "edit",    :default => false
    t.boolean "publish", :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "crypted_password",          :limit => 128, :default => "", :null => false
    t.string   "salt",                      :limit => 128, :default => "", :null => false
    t.string   "remember_token"
    t.string   "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.integer  "login_count",                              :default => 0,  :null => false
    t.integer  "failed_login_count",                       :default => 0,  :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "company"
    t.string   "telephone"
    t.string   "state"
  end

end
