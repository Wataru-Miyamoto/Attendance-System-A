class Attendance < ApplicationRecord
  belongs_to :user
    
  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  
  validate :finished_at_is_invaild_without_a_started_at
  validate :started_at_than_finished_at_fast_if_invalid
  
  enum monthly_confirmation_status: { nothing: 0, pending: 1, approval: 2, denial: 3 }

  def finished_at_is_invaild_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
  
  # 【所属長承認のお知らせ】一ヶ月支持者確認がログインユーザーで、ステータスが未承認かどうか＆何月分の勤怠
  def self.monthly_confirmation(current_user)
    attendances = self.where(monthly_confirmation_status: :pending, monthly_confirmation_approver_id: current_user.id)
    year_month_arr = []
    attendances.all.each do |attendance|
      year_month_arr << attendance.attendance_date.year.to_s + attendance.attendance_date.month.to_s
    end
    year_month_arr.uniq.count
  end
end
