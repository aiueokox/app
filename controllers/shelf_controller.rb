class ShelfController < ApplicationController
  def list
    if current_user.role_id.slice(4) >= "0"
      @shelves = Shelf.order(id: :asc)
    else
      flash[:alert] = "権限がありません"
      redirect_to request.referer
    end
  end
  def create
    @shelf = Shelf.new(room: params[:room],remark: params[:remark],user_id: current_user.id)
    @shelf.save
    flash[:alert] = "登録しました"
    redirect_to "/shelf/register"
  end
end
