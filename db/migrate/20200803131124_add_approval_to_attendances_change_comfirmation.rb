class AddApprovalToAttendancesChangeComfirmation < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edit_started_at, :datetime
    add_column :attendances, :edit_finished_at, :datetime
    add_column :attendances, :changed_started_at, :datetime
    add_column :attendances, :changed_finished_at, :datetime
  end
end
