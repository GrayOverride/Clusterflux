# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130513183906) do

  create_table "admin_news", :force => true do |t|
    t.string   "title"
    t.string   "desc"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "admin_updates", :force => true do |t|
    t.string   "title"
    t.string   "desc"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "admin_users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "pw_hash"
    t.string   "pw_salt"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "admins", :force => true do |t|
    t.string   "New"
    t.string   "title"
    t.string   "desc"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cards", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "upkeep"
    t.integer  "energy"
    t.integer  "atk"
    t.integer  "def"
    t.integer  "gank"
    t.integer  "faction_id"
    t.integer  "type_id"
    t.boolean  "publish"
    t.string   "avatar"
    t.integer  "scout_id"
    t.integer  "flip_id"
    t.integer  "deploy_id"
    t.integer  "passive_id"
  end

  create_table "decks", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "cards"
    t.integer  "user_id"
    t.integer  "hq"
  end

  create_table "effects", :force => true do |t|
    t.string   "name"
    t.string   "etype"
    t.string   "effect"
    t.integer  "amount"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "factions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "monologue_posts", :force => true do |t|
    t.integer  "posts_revision_id"
    t.boolean  "published"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "monologue_posts_revisions", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.string   "url"
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "published_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "monologue_posts_revisions", ["id"], :name => "index_monologue_posts_revisions_on_id", :unique => true
  add_index "monologue_posts_revisions", ["post_id"], :name => "index_monologue_posts_revisions_on_post_id"
  add_index "monologue_posts_revisions", ["published_at"], :name => "index_monologue_posts_revisions_on_published_at"
  add_index "monologue_posts_revisions", ["url"], :name => "index_monologue_posts_revisions_on_url"

  create_table "monologue_taggings", :force => true do |t|
    t.integer "post_id"
    t.integer "tag_id"
  end

  add_index "monologue_taggings", ["post_id"], :name => "index_monologue_taggings_on_post_id"
  add_index "monologue_taggings", ["tag_id"], :name => "index_monologue_taggings_on_tag_id"

  create_table "monologue_tags", :force => true do |t|
    t.string "name"
  end

  add_index "monologue_tags", ["name"], :name => "index_monologue_tags_on_name"

  create_table "monologue_users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "news", :force => true do |t|
    t.string   "title"
    t.string   "desc"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "servers", :force => true do |t|
    t.string   "name"
    t.boolean  "publish"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "key"
    t.integer  "user_id"
    t.string   "username"
    t.boolean  "ready"
    t.text     "state"
  end

  create_table "types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "username"
    t.string   "pw_hash"
    t.string   "pw_salt"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
