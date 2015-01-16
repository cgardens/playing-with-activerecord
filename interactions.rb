require 'active_record'

`rm interactions.db`

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  'interactions.db'
)


ActiveRecord::Migration.create_table :people do |t|
  t.string :name
  t.integer :role_id
end

ActiveRecord::Migration.create_table :roles do |t|
  t.string :label
end

ActiveRecord::Migration.create_table :moments do |t|
  t.integer :person_id
  t.integer :interaction_id
end

ActiveRecord::Migration.create_table :interactions do |t|
  t.string :label
end

ActiveRecord::Migration.create_table :perspectives do |t|
  t.integer :moment_id
  t.integer :satisfaction
end

ActiveRecord::Migrator.up 'nothing'

# -----

class Person < ActiveRecord::Base
  belongs_to :role

  has_many :moments
  has_many :interactions, through: :moments

  scope :random, -> { all.sample }
end

class Role < ActiveRecord::Base
  has_many :people

  # moonshot 1
  scope :labels , ->{ all.map(&:label).map(&:downcase) }
end

class Moment < ActiveRecord::Base
  belongs_to :person
  belongs_to :interaction
  has_one :perspective
end

class Interaction < ActiveRecord::Base
  has_many :moments
  has_many :people, through: :moments
  has_many :perspectives, through: :moments

  # moonshot 1
  def method_missing(*args)
    role = args.first.to_s.singularize

    if Role.labels.include? role
      self.people.where(role: Role.find_by(label: role.capitalize))
    else
      super
    end
  end
end

class Perspective < ActiveRecord::Base
  belongs_to :moment
  has_one :person, through: :moment
end

# ----
roles = %w[Student Teacher Coach]
students = %w[Charles Banu Gabriel]
teachers = %w[Sherif]

roles.map!{|label| Role.create(label: label)}
students.map!{|name| Person.create(name: name, role: Role.find_by(label: 'Student'))}
teachers.map!{|name| Person.create(name: name, role: Role.find_by(label: 'Teacher'))}

p roles
p students
p teachers

# how do we model a pairing session? (2 students)
# pair = students.sample(2)
# pairing_session = Interaction.create(label: 'AM pairing session')
# pair.each {|student| student.interactions << pairing_session}

# p Moment.all
# p Interaction.first.people

# # how do we prompt people for their perspective on an interaction?
# interaction = Interaction.first

# if interaction.perspectives.empty?
#   # puts "prompt user"
#   # p interaction
#   interaction.moments.each do |moment|
#     puts "#{moment.person.name}, please enter your perspective on #{interaction.label}"
#     perspective = gets.chomp.to_i
#     moment.create_perspective(satisfaction: perspective)
#   end
# else
#   puts "all set"
# end

# p Perspective.all.map{|perspective| "#{perspective.person.name} felt it was a #{perspective.satisfaction}"}

########################################################################
# how do we model a lecture? (1 teacher, all students)
am_lecture = Interaction.create(label: 'AM Lecture')
pm_lecture = Interaction.create(label: 'PM Lecture')

# moonshot 1
# p lecture.people.where(role: Role.find_by(label: 'Student'))
# if lecture.students.empty?
#   puts "no students attended this lecture"
# end

# p lecture
# puts lecture.methods.sort - ActiveRecord::Base.instance_methods
# lecture.people.create_person(name: 'Banu')
# p Moment.all

# lecture.people << students.sample

# p Moment.all

puts "-"*20
am_lecture.people << students.sample(2) << teachers
pm_lecture.people << students.sample(3) << teachers

puts "------"
p "AM Lecture Attedance"
# p am_lecture.people.where(role: Role.find_by(label: 'Student'))
puts "teachers:"
p am_lecture.teachers.map(&:name)
puts "students:"
p am_lecture.students.map(&:name)

puts "------"
p "PM Lecture Attedance"
# p pm_lecture.people.where(role: Role.find_by(label: 'Student'))
puts "teachers:"
p pm_lecture.teachers.map(&:name)
puts "students:"
p pm_lecture.students.map(&:name)

puts "------"
p "Student History"
students.each do |student|
  puts "#{student.name} attended #{student.interactions.map(&:label)}"
end



