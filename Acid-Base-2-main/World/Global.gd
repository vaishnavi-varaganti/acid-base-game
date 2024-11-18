extends Node

var current_level = 1
var acidArray = []
var baseArray = []
var compoundArray = []
var individualCompoundArray = []
var neitherArray = []
var correct_answer = ""  # Variable to store the correct answer for each question
var acidShooted = false
var baseShooted = false 
var level1Score = 0
var level2Score = 0
var level3Score = 0
var level4Score = 0
var api_url_lvl4 = "https://retoolapi.dev/JgRl9e/reactions"
var reactionIndex = -1
var api_url1 = "https://retoolapi.dev/Jqmkez/questions"
@onready var http_request = HTTPRequest.new()
var question_number = 0
var level1_correctAnswers = 0
var level2_correctAnswers = 0
var level3_correctAnswers = 0
var level4_correctAnswers = 0
var firstName = ""
var lastName = ""
var sid = ""
var user_id = ""
var level1Cleared = false
var level2Cleared = false
var level3Cleared = false
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(http_request)  # Add the HTTPRequest node dynamically to the scene tree
	preload_compound_data()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func set_user_info(f_name: String, l_name: String, student_id: String) -> void:
	firstName = f_name
	lastName = l_name
	sid = student_id
	print("User information is: ", firstName + " " + lastName + " " + sid)
	
# Function to preload compoundArray from the API
func preload_compound_data():
	print("Preloading compound data for Level 4...")
	http_request.request("https://retoolapi.dev/JgRl9e/reactions")
	
	# Connect the request completed signal if not already connected
	if not http_request.is_connected("request_completed", _on_HTTPRequest_request_completed):
		http_request.connect("request_completed", _on_HTTPRequest_request_completed)

# Handle the API response
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			var data = json.get_data()
			for entry in data:
				var formatted_compound = format_compound(entry["Reaction"])
				compoundArray.append([formatted_compound, "Compound"])
				individualCompoundArray.append([entry["Answer"], "Compound"])
				Global.compoundArray.append([formatted_compound, "Compound"])
				Global.individualCompoundArray.append([entry["Answer"], "Compound"])
			print("Compound data preloaded successfully!")
			set_reaction_index()
		else:
			print("Error parsing JSON.")
	else:
		print("Failed to load compound data. Status code: ", response_code)
		
func format_compound(compound: String) -> String:
	var formatted = "[font_size=30]"
	for char in compound:
		if '0' <= char and char <= '9': 
			formatted += "[font_size=20]" + char + "[/font_size]"
		else:
			formatted += char
	formatted += "[/font_size]"
	return formatted
	
func set_reaction_index():
	if compoundArray.size() > 0:
		reactionIndex = randi_range(0, compoundArray.size() - 1) # Set a random index within the range
		Global.reactionIndex = randi_range(0, compoundArray.size() - 1)
		#Global.correct_answer = individualCompoundArray[reactionIndex]
		print("New reactionIndex set: ", reactionIndex)
	else:
		print("Compound array is empty, cannot set reactionIndex.")
