require_relative 'questionsdatabase.rb'
require_relative 'user.rb'
require_relative 'question.rb'
require_relative 'questionlike.rb'
require_relative 'questionfollow.rb'

class Reply
  attr_reader :id
  attr_accessor :subject_question_id, :parent_reply_id, :user_id, :body
  def initialize(options={})
    @id = options['id']
    @subject_question_id = options['subject_question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    Reply.new(data.first)
  end

  def self.find_by_user_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        subject_question_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end

  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    User.new(data.first)
  end

  def question
    Question.find_by_id(@subject_question_id)
  end

  def parent_reply
    raise 'No parent of top-level reply' if @parent_reply_id == nil
    Reply.find_by_id(@parent_reply_id)
  end

  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL
    raise "No reply children" if data.empty?
    data.map { |datum| Reply.new(datum) }
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @subject_question_id, @parent_reply_id, @user_id, @body)
      INSERT INTO
        replies (subject_question_id, parent_reply_id, user_id, body)
      VALUES
        (?, ?, ?, ?)
      SQL
      "OK"
    else
      print "Updating..."
      QuestionsDatabase.instance.execute(<<-SQL, @subject_question_id, @parent_reply_id, @user_id, @body, @id)
      UPDATE
        replies
      SET
        subject_question_id = ?, parent_reply_id = ?,  user_id = ?, body = ?
      WHERE id = ?
      SQL
      "OK"
    end
  end
end
