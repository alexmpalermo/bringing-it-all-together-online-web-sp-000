class Dog 
  attr_accessor :name, :breed 
  attr_reader :id 
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table 
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
     sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end 
  
  def save 
    if self.id
    self.update
  else
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
  self 
  end 
  
  def self.create(hash) 
    dog = Dog.new(hash)
    hash.each do |k, v|
      dog.send("#{k}=", v)
    end
    dog.save
    dog 
  end 
  
  def self.find_by_id(id)
     sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, id).map do |row|
    self.new_from_db(row)
  end.first
  end
  
  def self.new_from_db(row)
    hash = {}
    hash[:name] = "#{row[1]}"
    hash[:breed] = "#{row[2]}"
    Dog.create(hash)
  end 
  
  def self.find_by_name(name)
     sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name).map do |row|
    self.new_from_db(row)
  end.first 
end 
   
  
def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      doggy = self.new_from_db(dog)
    else
      doggy = self.create(name: name, breed: breed)
    end
    doggy
  end 
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
  
end