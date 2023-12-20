extends MeshInstance3D
var scaredTime
var sound
# Called when the node enters the scene tree for the first time.
func _ready():
	sound = get_node("spook")
	scare()
	pass # Replace with function body.

func scare():
	var timer = randf_range(5,15)
	await get_tree().create_timer(timer).timeout
	sound.play()
	self.position += Vector3(0,0,1)
	await get_tree().create_timer(1.5).timeout
	self.position -= Vector3(0,0,1)
	sound.stop()
	scare()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
