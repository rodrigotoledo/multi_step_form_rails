class UsersController < ApplicationController
  before_action :set_user, only: %i[show update update_step]
  def new
    @user = User.new(step: 1)
  end

  def create
    @user = User.find_by(id: params[:id])
    @user ||= User.new
    @user.attributes = user_params.merge(step: 1)
    if @user.save
      render turbo_stream: turbo_stream.update("user_form", partial: "users/steps/step_2")
    else
      render :new
    end
  end

  def show
  end


  def update
    if @user.update(user_params)
      if @user.step == 3
        render turbo_stream: turbo_stream.update("user_form", template: "users/show")
      else
        render turbo_stream: turbo_stream.update("user_form", partial: "users/steps/step_#{@user.step+1}")
      end
    else
      render turbo_stream: turbo_stream.update("user_form", partial: "users/steps/step_#{@user.step}")
    end
  end

  def update_step
    @user.update(step: params[:step])
    render turbo_stream: turbo_stream.update("user_form", partial: "users/steps/step_#{params[:step]}")
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :age, :address, :step)
  end
end
