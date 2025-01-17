require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  ## Instance Methods
  def save 
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].last_insert_row_id
      self
    end
  end

  def update 
    sql = <<-SQL
        UPDATE students
        SET name = ?, grade = ? 
        WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
  end



  ## Class Methods
  def self.create_table 
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        name TEXT
        grade INTEGER
      )
    SQL

    DB[:conn].execute(sql)
  end
  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end
  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end
  def self.new_from_db(array)
    
    id = array[0]
    name = array[1]
    grade = array[2]

    Student.new(name, grade, id)
  
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students 
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end
end
