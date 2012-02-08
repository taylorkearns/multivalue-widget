require 'sinatra'
require 'data_mapper'

# Routes
get '/' do

	@user = User.first
	@skills = Skill.all
	
	@skills = @skills.count > 0 ? order_and_organize(@skills) : @skills
	
	erb :index
	
end

put '/' do

	erb :index

end

# Models
class Skill
	include DataMapper::Resource
	
	property :id, Serial
	property :name, String, :required => true
	property :parent_id, Integer
	
	has n, :users, :through => Resource
end

class User
	include DataMapper::Resource
	
	property :id, Serial
	property :last_name, String, :required => true
	property :first_name, String, :required => true
	
	has n, :skills, :through => Resource
end

def children?(skill_id)
	Skill.all(:parent_id => skill_id).count > 0
end

def build_children(skill)
	html = '<ul>'
	
	children = Skill.all(:parent_id => skill[:id])
	children.each do |child|
		html += '<li>'+child[:name]
		if children?(child[:id])
			html += '<img class="open arrow" src="images/open.png"/>'
			build_children(child)
		end
	end
	
	html += '</ul>'			
	html	
end

def order_and_organize(skills)
	html = '<ul>'
	
	# Get all of the root level skills
	skills.each do |skill|
		if skill[:parent_id] === nil
			html += '<li>'+skill[:name]
			
			if children?(skill[:id])
				html += '<img class="open arrow" src="images/open.png"/>'
				build_children(skill)
			end
			
			html += '</li>'
		end
	end
		
	html += '</ul>'	
	html
end

# Datamapper setup
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite:///Users/tkearns/_projects/TK/ruby/multivalue-widget/multivalue-widget/multivalue_widget.db')
DataMapper.finalize
DataMapper.auto_migrate!
#DataMapper.auto_upgrade!

@u = User.create(:first_name => 'Taylor', :last_name => 'Kearns')
p @u
@s1 = Skill.create(:name => 'Programming')
p @s1
@s2 = Skill.create(:name => 'Ruby', :parent_id => 1)
p @s2
@s3 = Skill.create(:name => 'Javascript', :parent_id => 1)
p @s3
@s4 = Skill.create(:name => 'Python', :parent_id => 1)
p @s4
@s11 = Skill.create(:name => 'Exercise')
p @s11[:parent_id]
@s12 = Skill.create(:name => 'Squats', :parent_id => 5)
p @s12
@s13 = Skill.create(:name => 'Dead Lifts', :parent_id => 5)
p @s13
@s14 = Skill.create(:name => 'Bench Press', :parent_id => 5)
p @s14[:parent_id]