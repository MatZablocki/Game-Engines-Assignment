extends Node3D
var roomConnectionsReal
var allRooms = {"room_crossroads": [1,1,1,1], "room_corridor_z": [1,2,1,2], "room_corridor_x": [2,1,2,1], "X-Z-": [2,1,1,2], "X+Z-": [2,2,1,1], "X-Z+": [1,1,2,2], "X+Z+": [1,2,2,1]}
var dimentions = Vector3(2,0,2)
var stack = {}
var notloaded = true
var availability #U,R,D,L Z+,X-,Z-,X+

# Called when the node enters the scene tree for the first time.
func _ready():
	var roomConnectionsPossible = check_existing_connections()
	
	roomConnectionsReal = get_availability(roomConnectionsPossible)
	var roomDesc = allRooms.find_key(roomConnectionsReal) 
	var roomString = "res://Rooms/"+roomDesc+".tscn"
	var room = load(roomString)
	var current_room = room.instantiate()

	call_deferred("add_child", current_room)
	pass


func get_availability(possibleConn):
	var temp = allRooms.duplicate()

	for room in allRooms: 
		for i in range(4):
			if(possibleConn[i] == 0):
				continue

			if((allRooms[room])[i] != possibleConn[i]):
				temp.erase(room)
				break
	if(temp.size() <= 0):
		temp = {"room_crossroads": [1,1,1,1]}
	return temp.values()[randi() % temp.size()]

func check_existing_connections():
	# Create a RayCast2D to check for collisions
	var raycast 
	var temp = [0,0,0,0]
	
	raycast = get_node("z-plus")
	raycast.force_raycast_update()
	if(raycast.is_colliding()):
		temp[0] = raycast.get_collider().get_parent().roomConnectionsReal[2]
	else:
		temp[0] = 0
	#print("up ", raycast.is_colliding())

	raycast = get_node("x-minus")
	raycast.force_raycast_update()
	#print("right ", raycast.is_colliding())
	if(raycast.is_colliding()):
		temp[1] = raycast.get_collider().get_parent().roomConnectionsReal[3]
	else:
		temp[1] = 0

	raycast = get_node("z-minus")
	raycast.force_raycast_update()
	#print("down ", raycast.is_colliding())
	if(raycast.is_colliding()):
		temp[2] = raycast.get_collider().get_parent().roomConnectionsReal[0]
	else:
		temp[2] = 0

	raycast = get_node("x-plus")
	raycast.force_raycast_update()
	#print("left ", raycast.is_colliding())
	if(raycast.is_colliding()):
		temp[3] = raycast.get_collider().get_parent().roomConnectionsReal[1]
	else:
		temp[3] = 0
	return temp


func is_position_occupied():
	var raycast 
	availability = []

	raycast = get_node("z-plus")
	raycast.force_raycast_update()

	availability.append(!raycast.is_colliding())

	raycast = get_node("x-minus")
	raycast.force_raycast_update()

	availability.append(!raycast.is_colliding())

	raycast = get_node("z-minus")
	raycast.force_raycast_update()

	availability.append(!raycast.is_colliding())

	raycast = get_node("x-plus")
	raycast.force_raycast_update()

	availability.append(!raycast.is_colliding())
	# Return true if there is a collision (position is occupied)
	return availability

func loader():
	var room = load("res://Rooms/room_checker.tscn")
	var temp
	stack = {}
	is_position_occupied()
	
	print(availability)
	if availability[0] == true:
		var current_room = room.instantiate()
		temp = self.position
		temp.z += dimentions.z
		current_room.position = temp
		call("add_sibling", current_room)
		stack["up"] = current_room

#	#Right
	if availability[1] == true:
		var current_room = room.instantiate()
		temp = self.position
		temp.x -= dimentions.x
		current_room.position = temp
		call("add_sibling", current_room)
		stack["right"] = current_room
	#Down
	if availability[2] == true:
		var current_room = room.instantiate()
		temp = self.position
		temp.z -= dimentions.z
		current_room.position = temp
		call("add_sibling", current_room)
		stack["down"] = current_room
	#Left
	if availability[3] == true:
		var current_room = room.instantiate()
		temp = self.position
		temp.x += dimentions.x
		current_room.position = temp
		call("add_sibling", current_room)
		stack["left"] = current_room

	pass






func _on_area_3d_body_entered(body):
	if(notloaded):
		loader()
		notloaded = false
	pass # Replace with function body.



