require File.dirname(__FILE__) + '/../../spec_helper'

describe "/home/index.haml" do
    
  before(:each) do
    assigns[:question_list] = []
  end

  it "should have the button to get question" do
    render "/home/index.haml"
    response.should have_tag("a[href=?]", new_answer_path)
  end
  
  it "should list answered question" do
    assigns[:question_list] << mock_answered_question
    render "/home/index.haml"
  end

  it "should list login user's head and question" do
    login_as :po
    
    question = mock_model(Question)
    question.should_receive(:content).and_return("q2")
    question.should_receive(:created_at).and_return(2.minutes.ago)
    
    assigns[:user_unanswer_question_list] = [question]
    assigns[:user_answered_question_list] = []
    
    render "/home/index.haml"
  end

  it "should list login user's question which answered by someone" do
    @user = login_as :po
    
    assigns[:user_unanswer_question_list] = []
    assigns[:user_answered_question_list] = [mock_answered_question]
    
    render "/home/index.haml"
  end
  
  def mock_answered_question
    asker = mock_model(User)
    asker.should_receive(:head).and_return("default_head.gif")
    asker.should_receive(:login).and_return("mahb")
    responser = mock_model(User)
    responser.should_receive(:head).and_return("default_head.gif")
    responser.should_receive(:login).and_return("maggic")
    question = mock_model(Question)
    question.should_receive(:user).exactly(4).and_return(asker)
    question.should_receive(:content).and_return("q1")
    question.should_receive(:created_at).and_return(2.minutes.ago)
    answer = mock_model(Answer)
    answer.should_receive(:user).exactly(4).and_return(responser)
    answer.should_receive(:content).and_return("a1")
    answer.should_receive(:created_at).and_return(1.minutes.ago)
    question.should_receive(:answer).exactly(6).times.and_return(answer)
    question
  end
end
