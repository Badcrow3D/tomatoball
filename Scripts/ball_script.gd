extends RigidBody3D
	
func _ready():
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("obstacles"):
		if body.has_method("on_hit"):
			body.on_hit(self)
