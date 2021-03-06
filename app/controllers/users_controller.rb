class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: :edit
  before_action :superior_user, only: :edit
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_or_correct_user, only: [:edit, :update]
  before_action :set_one_month, only: :show
  
  def index
   @users = User.all
    respond_to do |format|
      format.html do
          #html用の処理を書く
      end 
      format.csv do
          #csv用の処理を書く
          send_data render_to_string, filename: "(ファイル名).csv", type: :csv
      end
    end
   if params[:search]
      @user = User.where('LOWER(name) LIKE ?', "%#{params[:search][:name].downcase}%").paginate(page: params[:page])
   else
      @user = User.paginate(page: params[:page])
   end
  end

  def import
    User.import(params[:file])
    redirect_to users_url
  end

  def show
    if @user.admin?
      flash[:info] = "管理者の勤怠画面は表示されません。"
      redirect_to users_url
    end
    @worked_sum = @attendances.where.not(started_at: nil).count
    @superiors = User && User.where(superior: true).where.not(id: current_user.id)
    # 上長画面で一ヶ月分勤怠申請のお知らせをカウントする
    if @user.superior == true
      @monthly_confirmation_count = Attendance.where(monthly_confirmation_approver_id: @user.id, monthly_confirmation_status: 1).count
      @change_confirmation_count = Attendance.where(change_confirmation_approver_id: @user.id, change_confirmation_status: 1).count
      @overwork_count = Attendance.where(overwork_approver_id: @user.id, overwork_status: 1).count
    end
    @approver = @user.attendances.find_by(worked_on: @first_day)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes!(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to users_url
    else
      flash[:danger] = "ユーザー情報の更新に失敗しました。"
      redirect_to users_url
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
    @users = User.all
  end
  
  def update_basic_info
    @users = User.all
      @users.each do |users|
        if users.update_attributes(basic_info_params)
          flash[:success] = "基本情報を更新しました。"
        else
          flash[:danger] = "更新が失敗しました。<br>" + @user.errors.full_messages.join("<br>")
        end
      end
    redirect_to @users
  end
  
  def working_employee
    @users = User.all.includes(:attendances)
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :password, :password_confirmation, :designated_work_start_time, :designated_work_end_time)
    end
    
    def basic_info_params
      params.require(:user).permit(:basic_time, :work_time)
    end
    
    def monthly_update_params
      #debugger
      params.require(:user).permit(attendances: [:date, :monthly_confirmation_approver_id, :monthly_confirmation_status, :overday_check])[:attendances]
    end
    
    def admin_or_correct_user
    @user = User.find(params[:id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "アクセス権限がありません。"
        redirect_to(root_url)
      end
    end

end