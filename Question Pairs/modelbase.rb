require_relative 'questionsdatabase.rb'
require 'rubygems'
require 'active_support/all'

class ModelBase

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM #{self.to_s.tableize}")
    data.map { |datum| self.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.to_s.tableize}
      WHERE
        id = ?
    SQL
    self.new(data.first)
  end

  def self.where(options)
    wheres = []
    options.each { |k, v| wheres << "#{k} = '#{v}'" }
    wheres = wheres.join(" AND ")
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.to_s.tableize}
      WHERE
        #{wheres}
    SQL
    data.map { |datum| self.new(datum) }
  end

end
