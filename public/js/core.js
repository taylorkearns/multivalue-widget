/* ================================================== */
/* FUNCTIONS
/* ================================================== */
var widget = function()
{
	var add_image = '<img class="add" src="images/add.png"/>';
	var remove_image = '<img class="remove" src="images/remove.png"/>';
	
	var getSkillId = function(skill)
	{
		return skill.attr('id').split('-')[1];
	};
	
	return {
		// Add skill to user
		add_skill: function(selected_skill)
		{
			var skill_id = getSkillId(selected_skill);
			
			selected_skill
			.append('<input type="hidden" name="skill[]" value="' + skill_id + '"/>')
			.children('img.add').replaceWith(remove_image)
			.end()
			.appendTo('#user-skills');
		},
		
		// Remove skill from user
		remove_skill: function(selected_skill)
		{
			var skill_id = getSkillId(selected_skill);
			var parent_skill_id = selected_skill.attr('data-parent');
			var parent_list = selected_skill.attr('data-parent') ? $('#skills #' + parent_skill_id + ' > ul') : $('#skills'); 
						
			selected_skill
			.children('img.remove').replaceWith(add_image)
			.end()
			.appendTo(parent_list)
			.find('input:hidden').remove();
		}
	};
}();

/* ================================================== */
/* DOCUMENT.READY
/* ================================================== */
$(document).ready(function()
{
	$('#skills li .add').live('click', function() { widget.add_skill($(this).parent('li')); });
	
	$('#user-skills li .remove').live('click', function() { widget.remove_skill($(this).parent('li')); });
});