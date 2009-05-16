# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  layout 'facebox'
  before_filter :check_xhr, :only => :new

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      self.current_user.update_attribute(:last_login, DateTime.now)
      self.current_user.remember_me unless self.current_user.remember_token?
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      flash[:notice] = "登录成功."
      flash[:play] = true unless is_admin?
    else
      flash.now[:error] = "错误的用户名或密码."
      params[:password] = nil
      render :action => 'create_error'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "退出成功."
    redirect_back_or_default('/')
  end
end
