require 'active_record'

`rm kindness.db`

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  'kindness.db'
)


ActiveRecord::Migration.create_table :students do |t|
  t.string :name
end

ActiveRecord::Migration.create_table :acts_of_kindnesses do |t|
  t.integer :student_id
  t.integer :recipient_id
  t.integer :magnitude

  t.timestamps
end

ActiveRecord::Migrator.up 'db/migrate'

# -----

class Student < ActiveRecord::Base
  has_many :kindnesses, class_name: 'ActsOfKindness'
  has_many :blessings, class_name: 'ActsOfKindness'

  scope :random, ->{ all.sample }
end

class ActsOfKindness < ActiveRecord::Base
  belongs_to :student
  belongs_to :recipient, class_name: 'Student'

  scope :greatest, ->{ order('magnitude DESC').limit(1).first }
  scope :earliest, ->{ order('created_at DESC').limit(1).first }
end

# ---

p Student.create(name: 'Charles')
p Student.create(name: 'Sherif')
p Student.create(name: 'Banu')
p Student.create(name: 'Gabriel')
p Student.all

# make people happy
10.times do
  Student.random.kindnesses.create(recipient: Student.random, magnitude: (1..100).to_a.sample)
end

# show all acts of kindness that a specific student gave?
p Student.first.kindnesses

# show all acts of kindness that a specific student received?
p Student.first.blessings

puts "-"*20
p act = ActsOfKindness.greatest
puts "#{act.student.name} was kind to #{act.recipient.name}"

puts "-"*20
p act = ActsOfKindness.earliest
puts "#{act.student.name} was kind to #{act.recipient.name}"
