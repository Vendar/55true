require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AnswersController do
  
  describe 'stub' do
    before(:each) do
      @previou_question = mock_model(Question)
      Question.stub!(:find_by_id).and_return(@previou_question)
      UnansweredQuestion.stub!(:for).and_return(@previou_question)
      UnansweredQuestion.stub!(:find_by_question_id).and_return(mock_model(UnansweredQuestion))
    end

    describe 'not logged' do
      it "cann't get a question." do
        xhr :get, :new
        response.should redirect_to(:controller => "users", :action => "new")
        flash[:notice].should == "请先注册或登录，注册只需6秒."
      end
    end

    describe 'logged' do
      before do
        login_as :quentin
      end

      it "should get a question." do
        xhr :get, :new
        assigns[:unanswer_question].should == @previou_question
        response.should render_template(:new)
      end

      it "should answer." do
        prepare_answer
        post :create, :answer => {:content => "Yes!"}, :question => {:content => "What?"}, :previou_question => @previou_question.id
        response.should render_template(:create)
      end

      it "answer require content." do
        prepare_answer
        @answer.should_receive(:valid?).and_return(false)
        @answer.should_receive(:errors).and_return(["error"])
        post :create, :answer => {:content => ""}, :question => {:content => "What?"}, :previou_question => @previou_question.id
        response.should render_template("create_error")
      end

      describe 'get no question' do
        it "should ask a question directly." do
          UnansweredQuestion.stub!(:for).and_return(nil)
          xhr :get, :new
          assigns[:unanswer_question].should be_nil
          response.should redirect_to(:controller => :questions, :action => :new)
        end
      end

      :private

      def prepare_answer
        @answer = mock_model(Answer, :question => @previou_question, :null_object => true)
        Answer.should_receive(:new).and_return(@answer)
        @answer.stub!(:valid?).and_return(true)
        @answer.stub!(:save!).and_return(true)
        @answer.stub!(:errors).and_return(ActiveRecord::Errors.new(@answer))
        @question = mock_model(Question, :null_object => true)
        Question.should_receive(:new).and_return(@question)
        @question.stub!(:valid?).and_return(true)
        @question.stub!(:save!).and_return(true)
        @question.stub!(:errors).and_return(ActiveRecord::Errors.new(@question))
      end
    end
  end

  it "should get a message while question was deleted." do
    login_as :quentin
    lambda do
      unanswer_question = UnansweredQuestion.for(users(:quentin))
      unanswer_question.destroy
      post :create, :answer => {:content => "Yes!"}, :question => {:content => "What?"}, :previou_question => unanswer_question.id
      response.should render_template(:create)
    end.should_not change(Answer, :count)
  end

  it "should delete a answer." do
    login_as :saberma
    lambda do
      xhr :delete, :destroy, :id => answers(:patpat_a5)
      Question.find(answers(:patpat_a5).question.id).is_answered.should be_false
    end.should change(Answer, :count).by(-1)
  end

  it "should not play if he has 5 unanswer question" do
    login_as :patpat
    xhr :get, :new
    response.should render_template(:wait)
  end

end
