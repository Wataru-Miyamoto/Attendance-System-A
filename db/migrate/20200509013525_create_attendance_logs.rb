class CreateAttendanceLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_logs do |t|
      t.date :attendance_date
      t.datetime :started_at_before_update
      t.datetime :finished_at_before_update
      t.datetime :started_at_after_update
      t.datetime :finished_at_after_update
      t.integer :change_confirmation_approver_id
      t.date :approval_date

      t.timestamps
    end
  end
end
