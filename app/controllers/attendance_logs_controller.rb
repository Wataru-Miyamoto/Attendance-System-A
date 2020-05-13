class AttendanceLogsController < ApplicationController
  def index
    @attendance_logs = AttendanceLog.all.order(created_at: :asc)
  end
end
