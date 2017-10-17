require_relative 'questionsdatabase.rb'
require_relative 'user.rb'
require_relative 'reply.rb'
require_relative 'questionlike.rb'
require_relative 'questionfollow.rb'

class Question
  attr_reader :id
  attr_accessor :title, :body, :author_id

  def initialize(options={})
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

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def save
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
      INSERT INTO
        questions (title, body, author_id)
      VALUES
        (?, ?, ?)
      SQL
      "OK"
    else
      print "Updating..."
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, author_id = ?
      WHERE
        id = ?
      SQL
      "OK"
    end
  end

end
