module UsersHelper
  
  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end
  
  def overtimes(overtime, finish)
    format("%.2f", (((overtime.hour - finish.hour) * 60) + (overtime.min - finish.min)) / 60.0)
  end
end