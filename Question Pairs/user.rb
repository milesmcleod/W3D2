require_relative 'questionsdatabase.rb'
require_relative 'question.rb'
require_relative 'reply.rb'
require_relative 'questionlike.rb'
require_relative 'questionfollow.rb'

class User
  attr_reader :id
  attr_accessor :fname, :lname
  def initialize(options={})
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

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        COUNT(COALESCE(question_likes.id, 0))/CAST(COUNT(DISTINCT (question_id))AS FLOAT)
      FROM
        questions
      LEFT OUTER JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        questions.author_id = ?

    SQL
    data.first.values.first
  end
  # a = Users.new
  # a.fname = "Hello"
  # a.lname = "World"
  # a.save
  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
      SQL
      "OK"
    else
      print "Updating..."
      QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE id = ?
      SQL
      "OK"
    end
  end

end
