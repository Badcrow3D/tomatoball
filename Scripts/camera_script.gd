extends Node3D

@export var mouse_sensitivity: float = 0.2

@onready var camera_pivot: Node3D = $CameraPivot

var vertical_rotation: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		vertical_rotation += -event.relative.y * mouse_sensitivity
		vertical_rotation = clampf(vertical_rotation, -70, 0.0)
		camera_pivot.rotation_degrees.x = vertical_rotation
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		get_tree().quit()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			$CameraPivot/Camera3D.position.z = maxf($CameraPivot/Camera3D.position.z - 0.5, 1.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			$CameraPivot/Camera3D.position.z = minf($CameraPivot/Camera3D.position.z + 0.5, 10.0)
		
