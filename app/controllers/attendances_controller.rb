class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :monthly_confirmation, :change_confirmation, :update_one_month, :index, :apply_overtime_form]
  before_action :logged_in_user, only: [:update, :edit_one_month, :index]
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
    @attendance = Attendance.where(params[:id])
    @superiors = User.where(superior: true).where.not(id: current_user.id)
    if @user.superior == true
      @change_confirmation_count = Attendance.where(change_confirmation_approver_id: @user.id, change_confirmation_status: "pending").count
    end
    time.finished_at.day + 1 if [:tomorrow_check] == "1"
  end
  
  def change_confirmation
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        if item[:change_confirmation_approver_id].present?
          if item[:note].blank?
            flash[:danger] = "備考を入力してください。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date])
          elsif item["edit_started_at(4i)"].blank? || item["edit_started_at(5i)"].blank? || item["edit_finished_at(4i)"].blank? || item["edit_finished_at(5i)"].blank?
            flash[:danger] = "変更申請したい時間を入力してください。"
            redirect_to attendances_edit_one_month_user_url(date: params[:date])
          end
          item[:change_confirmation_status] = "1"
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
        end
      end
      flash[:success] = "勤怠変更の申請を送信しました。"
      redirect_to user_url(current_user)
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、申請をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
    #debugger
  end
  
  def change_confirmation_form
    @user = User.find(params[:id])
    @attendance_date = Attendance.where(attendance_date: current_user.id)
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date
    @superiors = User.where(superior: true).where.not(id: current_user.id)
    @attendances = Attendance.where(change_confirmation_status: 1, change_confirmation_approver_id: current_user.id).order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
    @change_confirmation_count = Attendance.where(change_confirmation_approver_id: current_user.id, change_confirmation_status: 1).count
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        if item[:edit_one_month_check] == "1"
          attendance = Attendance.find(id)
          if item[:change_confirmation_status] == "2"
            attendance.changed_started_at = attendance.started_at if attendance.changed_started_at.nil?
            attendance.changed_finished_at = attendance.finished_at if attendance.changed_finished_at.nil?
            item[:started_at] = attendance.edit_started_at
            item[:finished_at] = attendance.edit_finished_at
          end
          attendance.update_attributes!(item)
        end
      end
    end
    flash[:info] = "勤怠変更申請情報を更新処理しました。ご確認ください。"
    redirect_to user_url(current_user.id)
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新処理をキャンセルしました。"
    redirect_to user_url(current_user.id)
  end
  
  def index
    @attendances = Attendance.where(change_confirmation_status: 2).order(worked_on: "ASC")
  end
  
  #一ヶ月分の勤怠申請
  def monthly_confirmation
    #@user = User.find(params[:user_id])
    #パラメーターでユーザーの名前を検索してidを入れる
    #_id = User.where(name: params[:user][:name]).first.id
    #一ヶ月分の勤怠検索して上長IDとステータスの申請して保存する
    #@attendance = @user.attendances.find_by(worked_on: params[:date])
    #@attendance.update_attributes(:monthly_confirmation_approver_id => _id, :monthly_confirmation_status => :pending)
    #flash[:success] = "1ヶ月分の勤怠申請を送信しました。"
    #redirect_to user_url(current_user)
    ActiveRecord::Base.transaction do
      monthly_update_params.each do |id, item|
        if item[:monthly_confirmation_approver_id].present?
          item[:monthly_confirmation_status] = "1"
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
          flash[:success] = "勤怠変更の申請を送信しました。"
          redirect_to user_url(current_user)
        else
          flash[:danger] = "申請先を入力してください。"
          redirect_to user_url(current_user)
        end
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、申請をキャンセルしました。"
    redirect_to user_url(current_user)
    #debugger
  end
  
    #上長承認モーダル画面・ユーザーからの1ヶ月分勤怠
  def monthly_confirmation_form
    @user = User.find(params[:id])
    @attendance_date = Attendance.where(attendance_date: current_user.id)
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @superiors = User.where(superior: true).where.not(id: current_user.id).map(&:name)
    #未承認かつidがcurrent_user
    @attendances = Attendance.where(monthly_confirmation_status: :pending, monthly_confirmation_approver_id: current_user.id)
    #ユーザー（user_id)ごとに勤怠のオブジェクトを分ける
    tmp_pending_users = @attendances.group_by(&:user_id)
    #未承認のユーザーの名前と、何月分の一ヶ月勤怠申請なのか
    @pending_users = {}
    tmp_pending_users.each do |user_id, attendances|
      year_month_arr = []
      attendances.each do |attendance|
        year_month_arr << attendance.attendance_date.to_s
      end
      year_month_arr.uniq
      @pending_users.store(User.find(user_id).name, year_month_arr.uniq)
    end
  end
  
  def monthly_update
    p params
    ActiveRecord::Base.transaction do
      monthly_update_params.each do |id, item|
        attendance = Attendance.find(id)
        item[:monthly_confirmation_status] = item[:monthly_confirmation_status].to_i
        attendance.update_attributes!(item) if item[:overday_check] == "1"
      end
    end
    flash[:info] = "1ヶ月分の勤怠申請を更新処理しました。ご確認ください。"
    redirect_to user_url(current_user.id)
  end
  
  def apply_overtime_form
    @attendance = Attendance.where(params[:id])
    @superiors = User.where(superior: true).where.not(id: current_user.id)
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date
    @worked_on = @user.attendances.find_by(worked_on: day)
    time.finished_at.day + 1 if [:tomorrow_check] == "1"
  end
  
  def apply_overtime
   ActiveRecord::Base.transaction do
      update_overtime_params.each do |id, item|
        if item[:overwork_approver_id].present?
          if item[:task_memo].blank?
            flash[:danger] = "業務処理内容を入力してください。"
            redirect_to user_url(current_user)
          elsif item["overtime(4i)"].blank? || item["overtime(5i)"].blank?
            flash[:danger] = "残業申請したい時間を入力してください。"
            redirect_to user_url(current_user)
          end
          item[:overwork_status] = "1"
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
        end
      end
      flash[:success] = "残業申請を送信しました。"
      redirect_to user_url(current_user)
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、申請をキャンセルしました。"
    redirect_to user_url(current_user)
      #redirect_to attendances_path, notice: '残業申請を送付しました。' 
      #redirect_to attendances_path, notice: '残業申請は失敗しました。' 
  end
  
  def update_overtime_form
    @user = User.find(params[:id])
    @attendance_date = Attendance.where(attendance_date: current_user.id)
    @first_day = params[:date].nil? ? Date.current.beginning_of_month : params[:date].to_date
    @superiors = User.where(superior: true).where.not(id: current_user.id)
    @attendances = Attendance.where(overwork_status: 1, overwork_approver_id: current_user.id).order(user_id: "ASC", worked_on: "ASC").group_by(&:user_id)
    @overwork_count = Attendance.where(overwork_approver_id: current_user.id, overwork_status: 1).count
  end
  
  
  private
  
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :edit_started_at, :edit_finished_at, :note, :change_confirmation_approver_id, :change_confirmation_status, :tomorrow_check, :edit_one_month_check])[:attendances]
    end
    
    def monthly_update_params
      #debugger
      params.require(:user).permit(attendances: [:date, :monthly_confirmation_approver_id, :monthly_confirmation_status, :overday_check])[:attendances]
    end
    
    def update_overtime_params
      params.require(:user).permit(attendances: [:overtime, :task_memo, :overwork_approver_id, :overwork_status, :tomorrow_check, :overwork_check])[:attendances]
    end
    
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "アクセス権限がありません。"
        redirect_to(root_url)
      end
    end
    
end