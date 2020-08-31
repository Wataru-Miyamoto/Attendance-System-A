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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200803131124) do

  create_table "attendance_logs", force: :cascade do |t|
    t.date "attendance_date"
    t.datetime "started_at_before_update"
    t.datetime "finished_at_before_update"
    t.datetime "started_at_after_update"
    t.datetime "finished_at_after_update"
    t.integer "change_confirmation_approver_id"
    t.date "approval_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "attendance_date"
    t.datetime "overtime"
    t.text "task_memo"
    t.integer "change_confirmation_approver_id"
    t.integer "change_confirmation_status"
    t.integer "overwork_approver_id"
    t.integer "overwork_status"
    t.integer "monthly_confirmation_approver_id"
    t.integer "monthly_confirmation_status"
    t.datetime "edit_started_at"
    t.datetime "edit_finished_at"
    t.datetime "changed_started_at"
    t.datetime "changed_finished_at"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.string "base_id"
    t.string "base_name"
    t.string "base_type"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bases_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "affiliation"
    t.integer "employee_number"
    t.string "uid"
    t.boolean "superior", default: false
    t.boolean "admin", default: false
    t.string "password_digest"
    t.string "remember_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "basic_time", default: "2020-05-08 23:00:00"
    t.datetime "designated_work_start_time", default: "2020-05-09 00:00:00"
    t.datetime "designated_work_end_time", default: "2020-05-09 09:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
