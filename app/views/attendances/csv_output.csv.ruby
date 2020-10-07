require 'csv'
CSV.generate do |csv|
  csv_column_names = ["日付","出社時間","退社時間"]
  csv << csv_column_names
  @attendances.each do |product|
    csv_column_values = [
      product.worked_on.strftime("%m/%d"),
      product.started_at.present? ? product.started_at.strftime("%I:%M") : nil,
      product.finished_at.present? ? product.finished_at.strftime("%I:%M") : nil
    ]
    csv << csv_column_values
  end
end