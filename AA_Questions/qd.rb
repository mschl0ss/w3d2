require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

# ----------------------------------------------------------#
# ----------------------------------------------------------#

class User

  attr_accessor :id, :fname, :lname

  def self.all
    data = QuestionsDatabase.instance.execute('SELECT * FROM users')
    data.map { |datum| User.new(datum) }
  end
  
  def self.find_by_id(id)
    datum = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    User.new(datum.first)
  end

  def self.find_by_name(fname, lname)
    datum = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT 
        *
      FROM 
        users
      WHERE 
        fname = ? AND lname = ?

    SQL

    User.new(datum.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end


end

# ----------------------------------------------------------#
# ----------------------------------------------------------#

class Question

  attr_accessor :id, :title, :body, :author_id

  def self.all
    data = QuestionsDatabase.instance.execute('SELECT * FROM questions')
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    datum = QuestionsDatabase.instance.execute(<<-SQL,id)
      SELECT *
      FROM questions
      WHERE id = ?
    SQL

    Question.new(datum.first)
  end

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL,author_id)
      SELECT *
      FROM questions
      WHERE author_id = ?
    SQL

    data.map { |datum| Question.new(datum) }

  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def author
    User.find_by_id(self.author_id)
  end

  def replies
    Reply.find_by_question_id(self.id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end
end

# ----------------------------------------------------------#
# ----------------------------------------------------------#

class QuestionFollow

  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDatabase.instance.execute('SELECT * FROM question_follows')
    data.map { |datum| QuestionFollow.new(datum)}
  end

  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      users
      JOIN question_follows ON users.id = question_follows.user_id
      JOIN questions ON question_follows.question_id =  questions.id
    WHERE
      questions.id = ?

    SQL

    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.id, questions.title, questions.body, questions.author_id
    FROM
      users
      JOIN question_follows ON users.id = question_follows.user_id
      JOIN questions ON question_follows.question_id =  questions.id
    WHERE
      users.id = ?

    SQL

    data.map { |datum| Question.new(datum) }    
  end

  def self.find_by_id
    #pretty sure this is useless
  end

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

end

# ----------------------------------------------------------#
# ----------------------------------------------------------#

class Reply

  attr_accessor :id, :question_id, :user_id, :body, :parent_id

  def self.all
    data = QuestionsDatabase.instance.execute('SELECT * FROM replies')
    data.map { |datum| Reply.new(datum)}
  end

  def self.find_by_id(id)
    datum = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM replies
      WHERE id = ?
    SQL
    
    Reply.new(datum.first)
  end

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM replies
      WHERE user_id = ?

    SQL

    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL,question_id)
      SELECT *
      FROM replies
      WHERE question_id = ?

    SQL
    data.map { |datum| Reply.new(datum)}
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @body = options['body']
    @parent_id = options['parent_id']
  end

  def author
    User.find_by_id(self.user_id)
  end

  def question
    Question.find_by_id(self.question_id)
  end

  def parent_reply
    Reply.find_by_id(self.parent_id)
  end

  def child_replies
    #search table for any row where parent_id == self.id
    data = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL

    data.map { |datum| Reply.new(datum) }
  end


end

# ----------------------------------------------------------#
# ----------------------------------------------------------#

class QuestionLike

  attr_accessor :id, :user_id, :question_id

  def self.all
    data = QuestionsDatabase.instance.execute('SELECT * FROM question_likes')
    data.map { |datum| QuestionLike.new(datum)}
  end

  def self.find_by_id(id)
    datum = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM question_likes
      WHERE id = ?
    SQL
    
    QuestionLike.new(datum.first)
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

end