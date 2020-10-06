module AttendancesHelper
  
  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
      false
  end
  
  def attendance_count
    Attendance.where(user_id: params[:id], attendance_date: Time.new(@first_day.year,@first_day.month).all_month).select("finished_at").count
  end
  
  # 在社時間計上用
  def working_hours(a,b)
    started_at = Time.mktime(a.year, a.month, a.day, a.hour, a.min, 0, 0)
    finished_at = Time.mktime(b.year, b.month, b.day, b.hour, b.min, 0, 0)
    #(((leaving_at - arriving_at) / 60) / 60).truncate()
    (Time.parse("1/1") + (finished_at - started_at)).strftime("%H時間%M分")
  end
  
  # 引数の時刻データの秒を０にして差を求める
  def times(x,y)
    c = Time.mktime(x.year, x.month, x.day, x.hour, x.min, 0, 0)
    d = Time.mktime(y.year, y.month, y.day, y.hour, y.min, 0, 0)
    (d - c).to_i
  end

  
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
  def overtimes(overtime, finish)
    format("%.2f", ((overtime.hour - finish.hour) + (overtime.min - finish.min) / 60.0))
  end
  
end