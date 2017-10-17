require_relative 'questionsdatabase.rb'
require_relative 'user.rb'
require_relative 'question.rb'
require_relative 'reply.rb'
require_relative 'questionlike.rb'

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
