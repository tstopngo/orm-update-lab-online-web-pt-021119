require_relative "../config/environment.rb"

class Student
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  
  attr_accessor :name, :grade, :id
  
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql_table = <<-SQL
    CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name TEXT,
    grade INTEGER
    )
    SQL
    
    DB[:conn].execute(sql_table)
  end

  def self.drop_table
    sql_drop_table = <<-SQL
    DROP TABLE students
    SQL
    
    DB[:conn].execute(sql_drop_table)
  end
  
  def save
    sql_save = <<-SQL
      INSERT INTO students (name, grade) VALUES (?,?)
    SQL
    
    if self.id
      self.update
    else
      DB[:conn].execute(sql_save, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql_query = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE ID = ?
    SQL
    
    DB[:conn].execute(sql_query, self.name, self.grade, self.id)
  end
  
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end
  
  def self.new_from_db(row)
    student = Student.new(row[1], row[2], row[0])
    student
  end
  
  def self.find_by_name(name)
    sql_query = <<-SQL
      SELECT * FROM students WHERE name = ?
      LIMIT 1
    SQL
    
    DB[:conn].execute(sql_query, name).map do |row|
      self.new_from_db(row)
    end.first
    
  end

  
end
