extends StaticBody3D
@onready var mesh_instance = $TargetMesh

func on_hit(hit_object: RigidBody3D) -> void:
	var tin = 0.08
	var tout = 0.4
	#var tw = create_tween().set_parallel(true)
	var tw = create_tween()
	tw.tween_property(mesh_instance, "rotation", Vector3(-0.5, 0, 0), tin)
	#tw.tween_property(mesh_instance, "scale", Vector3(1.2, 0.8, 1.2), tin)
	tw.tween_property(mesh_instance, "rotation", Vector3(0, 0, 0), tout).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	#tw.chain().tween_property(mesh_instance, "rotation", Vector3(0, 0, 0), tout).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	#tw.chain().tween_property(mesh_instance, "scale", Vector3(1, 1, 1), tout).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	
	
