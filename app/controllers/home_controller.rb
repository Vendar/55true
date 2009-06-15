class HomeController < ApplicationController
  def index
    #用户问的
    if logged_in?
      @user_unanswer_question_list = Question.unanswer.of current_user
      @user_answered_question_list = Question.limit(2).answered.of(current_user)
      @question_list = Question.answered.not_belong_to(current_user).paginate(:page => params[:page])
      flash.now[:notice] = "这里的#{User.all.size}个朋友(共玩了#{@question_list.total_entries}次)，点击下一行“我敢玩”继续吧!" unless flash[:notice]
      #用户收到的消息
      @message = Message.to(current_user).first
    else
      @question_list = Question.answered.paginate(:page => params[:page])
      flash.now[:notice] = "这里的#{User.all.size}个朋友(共玩了#{@question_list.total_entries}次)，想跟你一起玩真心话，点击下一行“我敢玩”就可以开始了!"
    end
  end

end
