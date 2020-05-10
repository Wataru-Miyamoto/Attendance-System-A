class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :index_log]
  before_action :logged_in_user, only: [:update, :edit_one_month, :index_log]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
    flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def index_log
  end
  
  #一ヶ月分の勤怠申請
  def monthly_confirmation
    @first_day = params[:year_month]
    #datetimeに変換
    @first_day = @first_day.to_datetime
    @last_day = @first_day.end_of_month
    #パラメーターでユーザーの名前を検索してidを入れる
    _id = User.where(name: params[:user][:name]).first.id
    #一ヶ月分の勤怠検索して上長IDとステータスの申請して保存する
    Attendance.where('attendance_date >= ? and attendance_date <= ?', @first_day-1.minute, @last_day).update_all(:monthly_confirmation_approver_id => _id, :monthly_confirmation_status => :pending)
  end
  
    #上長承認モーダル画面・ユーザーからの1ヶ月分勤怠
  def monthly_confirmation_form
    #未承認かつidがcurrent_user
    @attendances = Attendance.where(monthly_confirmation_status: :pending, monthly_confirmation_approver_id: current_user.id)
    #ユーザー（user_id)ごとに勤怠のオブジェクトを分ける
    tmp_pending_users = @attendances.group_by(&:user_id)
    #未承認のユーザーの名前と、何月分の一ヶ月勤怠申請なのか
    @pending_users = {}
    tmp_pending_users.each do |user_id, attendances|
      year_month_arr = []
      attendances.each do |attendance|
        year_month_arr << attendance.attendance_date.year.to_s + attendance.attendance_date.month.to_s
      end
      year_month_arr.uniq
      @pending_users.store(User.find(user_id).name, year_month_arr.uniq)
    end
  end
  
  def update_overtime
    #todo
    @attendance = Attendance.find(params[:id])
    
    tmp_date = @attendance.attendance_date
    tmp_hour = params[:attendance][:overtime].split(":")[0].to_i
    tmp_min = params[:attendance][:overtime].split(":")[1].to_i
    @attendance.overtime = tmp_date + tmp_hour.hour + tmp_min.minute
    
    #チェックボックスはifで分岐だけでデータベースには入れない
    if params[:overday_check]
      @attendance.overtime = @attendance.overtime + 1.day
    end 
    
    @attendance.user_id = current_user.id
    #指示者確認・パラメーターでユーザーの名前を検索してidを入れる
    @attendance.overwork_approver_id = User.where(name: params[:user][:name]).first.id
    @attendance.task_memo = params[:attendance][:task_memo]
    if @attendance.save
      redirect_to attendances_path, notice: '残業申請を送付しました。' 
    else
      redirect_to attendances_path, notice: '残業申請は失敗しました。' 
    end
  end
  
  
  private
  
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "アクセス権限がありません。"
        redirect_to(root_url)
      end
    end
    
    # 申請した上長idと申請月
    def update_month_params
    	params.permit(attendances: [:superior_id, :apply_month, :month_approval, :month_check])[:attendances]
    end
end