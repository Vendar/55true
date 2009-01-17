# == Schema Information
# Schema version: 20081103115406
#
# Table name: questions
#
#  id          :integer(4)      not null, primary key
#  content     :string(255)     default(""), not null
#  is_answered :boolean(1)      not null
#  user_id     :integer(4)      not null
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Question < ActiveRecord::Base
  belongs_to :user, :counter_cache => true
  has_one :answer

  #this value init when unanswered_question get
  attr_accessor :checksum

  validates_presence_of     :content
  
  named_scope :unanswer, :conditions => ['is_answered = ?', false], :order => "id asc"
  named_scope :answered, :conditions => ['is_answered = ?', true], :order => "updated_at desc", :limit => 20
  named_scope :of, lambda {|user|
    {:conditions => ['user_id = ?', user.id]}
  }
  named_scope :not_belong_to, lambda {|user|
    {:conditions => ['user_id != ?', user.id]}
  }
  named_scope :limit, lambda {|limit|
    {:limit => limit}
  }


  after_create do |question|
    UnansweredQuestion.create(:question => question, :play_time => MAX_ANSWER_TIME.ago)
  end

end
