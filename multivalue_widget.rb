require 'sinatra'
require 'data_mapper'

# ==================================================
# ROUTES
# ==================================================
get '/' do
	@user = User.first
	@user_skills = @user.all_skills
	skills_filter = SkillsFilter.new
	@skills = skills_filter.unassigned_skills(@user_skills)
	tree_builder = TreeBuilder.new
	@skills = @skills.count > 0 ? tree_builder.order_and_organize(@skills, @user_skills) : @skills
	
	erb :index
end

post '/user' do
	puts '>>> PARAMS <<<'
	params[:skill].each { |s| puts s }
		
	@user = User.first
	@user[:first_name] = params['first-name']
	@user[:last_name] = params['last-name']
	@user.save
	
	redirect to('/')
end

# ==================================================
# MODELS
# ==================================================
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
	
	def all_skills
		skills.all(:order => [:name])
	end
end

# ==================================================
# MODULES
# ==================================================
class TreeBuilder
	def children?(id)
		Skill.all(:parent_id => id).count > 0
	end
	
	def build_children(skill, user_skills)
		child_html = '<ul>'
		
		# Recursively traverse through child skills
		children = Skill.all(:parent_id => skill[:id])
		children.each do |child|
			if !user_skills.include?(child)
				child_html += '<li id="skill-' + child[:id].to_s + '" data-parent="skill-' + child[:parent_id].to_s + '">'+child[:name]
				if children?(child[:id])
					child_html += '<img class="open arrow" src="images/open.png"/>'
					child_html += build_children(child, user_skills)
				else
					child_html += '<img class="add" src="images/add.png"/>'
				end
				
				child_html += '</li>'
			end
		end
		
		child_html += '</ul>'			
		child_html	
	end
	
	def order_and_organize(skills, user_skills)
		html = '<ul id="skills">'
		
		# Get root level skills
		skills.each do |skill|
			if skill[:parent_id] === nil
				html += '<li id="skill-' + skill[:id].to_s + '">' + skill[:name]
				
				if children?(skill[:id])
					html += '<img class="open arrow" src="images/open.png"/>'
					html += build_children(skill, user_skills)
				else
					html += '<img class="add" src="images/add.png"/>'
				end
				
				html += '</li>'
			end
		end
			
		html += '</ul>'	
		html
	end
end

# ==================================================
# FUNCTIONS
# ==================================================
class SkillsFilter
	def unassigned_skills(user_skills)
		skills = Skill.all(:order => [:name])
		skills.each do |skill| 
			if user_skills.include?(skill)
				skills.delete(skill)
			end
		end
		skills
	end
end

# ==================================================
# DATAMAPPER SETUP
# ==================================================
DataMapper::Logger.new($stdout, :debug)
#DataMapper.setup(:default, 'sqlite:///Users/taykearns/Documents/Web/_projects/ruby/multivalue-widget/multivalue-widget/multivalue_widget.db')
DataMapper.setup(:default, 'sqlite:///Users/tkearns/_projects/TK/ruby/multivalue-widget/multivalue-widget/multivalue_widget.db')
DataMapper.finalize
DataMapper.auto_migrate!
#DataMapper.auto_upgrade!

# ==================================================
# TEST DATA
# ==================================================
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
p @s11
@s12 = Skill.create(:name => 'Weight Lifting', :parent_id => 5)
p @s12
@s121 = Skill.create(:name => 'Squats', :parent_id => 6)
p @s121
@s122 = Skill.create(:name => 'Dead Lifts', :parent_id => 6)
p @s122
@s123 = Skill.create(:name => 'Bench Press', :parent_id => 6)
p @s123
@s13 = Skill.create(:name => 'Cardio', :parent_id => 5)
p @s13
@s14 = Skill.create(:name => 'Agility', :parent_id => 5)
p @s14
@s15 = Skill.create(:name => 'Pottery')
p @s15
@s16 = Skill.create(:name => 'Crochet')
p @s16
@s17 = Skill.create(:name => 'Telepathy')
p @s17

@u.skills << @s2
@u.skills << @s3
@u.skills << @s17
@u.save

@u.skills.each { |user_skill| puts "USER SKILL >> #{ user_skill[:name] }" }








