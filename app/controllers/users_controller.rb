class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "注册成功!"
    else
      render :action => 'new'
    end
  end

  def update
    User.find(params[:id]).update_attribute(:photo, params[:user][:photo])
    redirect_to home_path
  end

  def show
    @user = User.find(params[:id])
    unless @user
      flash[:error] = "用户不存在!"
      redirect_to home_url and return
    end
    @his_answered_question_list = Question.limit(10).answered.of(@user)
    @his_answer_list = Answer.limit(10).of(@user)
    @his_answer_list = @his_answer_list.map(&:question)
  end
end
