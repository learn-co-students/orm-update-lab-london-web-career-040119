require_relative '../config/environment.rb'

class Student
  attr_reader :name, :grade
  attr_accessor :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        grade INTEGER
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
    SQL
    DB[:conn].execute(sql)
  end

  def update
    sql = <<-SQL
      UPDATE students SET
        name = ?,
        grade = ?
      WHERE id = ?;
    SQL
    DB[:conn].execute(sql, name, grade, id)
  end

  def save
    if id
      update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?,?);
      SQL
      DB[:conn].execute(sql, name, grade)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM students;')[0][0]
    end
  end

  def name=(new_name)
    @name = new_name
    save
  end

  def self.create(name, grade)
    student = new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?;
    SQL
    DB[:conn].execute(sql, name).map do |row|
      new_from_db(row)
    end.first
  end
end
