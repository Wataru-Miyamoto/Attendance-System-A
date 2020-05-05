class BasesController < ApplicationController
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '新規作成に成功しました。'
      redirect_to bases_url
    else
      render :new
    end
  end
  
  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
      flash[:success] = "拠点の更新に成功しました。"
      redirect_to bases_url
    else
      render :edit
    end
  end

  
  def edit
    @base = Base.find(params[:id])
  end
  
  def index
    @base = Base.all
  end
  
  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "#{@base.base_name}のデータを削除しました。"
    redirect_to bases_url
  end
    
    
  private
  
  def base_params
    params.require(:base).permit(:base_id, :base_name, :base_type)
  end

end
