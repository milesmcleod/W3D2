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
    if options.is_a?(Hash)
      wheres = []
      options.each { |k, v| wheres << "#{k} = '#{v}'" }
      wheres = wheres.join(" AND ")
    else
      wheres = options
    end
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


  def method_missing(method_name, *args)
    puts 'loop'
    method_name = method_name.to_s
    if method_name.start_with?("find_by_")
      attributes_string = method_name[("find_by_".length)..-1]
      attribute_names = attributes_string.split("_and_")
      unless attribute_names.length == args.length
        raise "unexpected # of arguments"
      end
      search_conditions = {}
      attribute_names.each_index do |i|
        search_conditions[attribute_names[i]] = args[i]
      end
      self.where(search_conditions)
    else
      super
    end
  end
end
