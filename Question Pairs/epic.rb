require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_reader :id
  attr_accessor :fname, :lname
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.all
    data = QuestionsDatabase.instance.execute('SELECT * FROM users')
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    User.new(data.first)
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname LIKE ? AND lname LIKE ?
    SQL
    User.new(data.first)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end


end

class Question
  attr_reader :id
  attr_accessor :title, :body, :author_id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    Question.new(data.first)
  end

  def self.find_by_author_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, @author_id)
      SELECT
        fname, lname
      FROM
        users
      WHERE
        id = ?
    SQL
    User.new(data.first)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

end

class Reply
  attr_reader :id
  attr_accessor :subject_question_id, :parent_reply_id, :user_id, :body
  def initialize(options)
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


end

class QuestionLike
  attr_reader :id
  attr_accessor :user_id, :question_id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    data.map { |datum| QuestionLike.new(datum) }
  end
end

class QuestionFollow
  attr_reader :id
  attr_accessor :user_id, :question_id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      users
    JOIN
      question_follows ON users.id = question_follows.user_id
    WHERE
      question_follows.question_id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      questions
    JOIN
      question_follows ON questions.id = question_follows.question_id
    WHERE
      question_follows.user_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      *
    FROM
      questions
    LEFT JOIN
      question_follows ON questions.id = question_follows.question_id
    GROUP BY
      questions.id
    ORDER BY
      COUNT(question_follows.user_id) DESC
    LIMIT
      ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

end
