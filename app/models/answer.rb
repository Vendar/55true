# == Schema Information
# Schema version: 20081103115406
#
# Table name: answers
#
#  id          :integer(4)      not null, primary key
#  content     :string(255)     default(""), not null
#  question_id :integer(4)      not null
#  user_id     :integer(4)      not null
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :user, :counter_cache => true
  
  validates_presence_of     :content
  validates_length_of       :content, :maximum => 120, :allow_nil => true

  named_scope :with_question, lambda {
    {
      :joins => :question,
      :order => "updated_at desc"
    }
  }
  #homepage dynamic refresh
  named_scope :newer, lambda {|id|
    {
      :conditions => ['id > ?', id], 
      :order => "id asc",
      :limit => 1
    }
  }

  named_scope :of, lambda {|user|
    {:conditions => ["answers.user_id = ?", user.id], :order => "updated_at desc"}
  }

  named_scope :question_of, lambda {|user|
    {:conditions => ["questions.user_id = ?", user.id], :order => "updated_at desc"}
  }

  named_scope :limit, lambda {|limit|
    {:limit => limit}
  }

  def self.per_page
    10
  end

  def validate_on_create
    errors.add_to_base(I18n.translate('activerecord.errors.messages.timeout')) if timeout?
  end

  before_create do |answer|
    answer.question.update_attribute(:is_answered, true)
  end

  after_create do |answer|
    UnansweredQuestion.delete_all(["question_id = ?", answer.question])
    #清除首页动态更新的缓存
    expire_memcache "answers_#{answer.id-1}"
  end

  after_destroy do |answer|
    question = answer.question
    question.update_attribute :is_answered, false
    UnansweredQuestion.create_from question
  end

  def timeout?
    #问题删除后相当于超时
    return true if question.nil?
    uq = UnansweredQuestion.find_by_question_id question.id
    uq.nil? || uq.player != user
  end
end
