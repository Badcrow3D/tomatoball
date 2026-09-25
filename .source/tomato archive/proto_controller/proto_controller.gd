extends CharacterBody3D

@export var can_move : bool = true
@export var has_gravity : bool = true
@export var can_jump : bool = true
@export var can_sprint : bool = false
@export var can_freefly : bool = false
@export var can_hold : bool = true

@export_group("Speeds")
@export var look_speed : float = 0.016
@export var base_speed : float = 7.0
@export var jump_velocity : float = 4.5
@export var sprint_speed : float = 10.0
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
@export var input_left : String = "ui_left"
@export var input_right : String = "ui_right"
@export var input_forward : String = "ui_up"
@export var input_back : String = "ui_down"
@export var input_jump : String = "ui_accept"
@export var input_sprint : String = "sprint"
@export var input_freefly : String = "freefly"
@export var input_hold : String = "hold"
@export var input_throw : String = "throw"

@export_group("Hold Settings")
@export var GRAB_DISTANCE := 2.5
@export var HOLD_SMOOTHNESS := 10.0
@export var hold_distance := 2.5
@export var throw_maxtime = 3.0
@export var throw_maxpower = 10.0

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false
var holding : bool = false
var throw_start : float = 0.0
var throw_end : float = 0.0
var throw_direction : Vector3 = Vector3.UP
var throw_amount : float = 0.0
		
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider

@onready var camera: Camera3D = $Head/MainCamera
var held_object: RigidBody3D = null
var throw_object: RigidBody3D = null

func _ready() -> void:
	capture_mouse()
	#check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

func _try_pickup():
	var viewport := get_viewport()
	var center := viewport.get_visible_rect().size / 2.0
	var from := camera.project_ray_origin(center)
	var to := from + camera.project_ray_normal(center) * GRAB_DISTANCE
	
	var space_state := get_world_3d().direct_space_state
	var result := space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	
	#if result and result.collider.name == "Ball":
	if result:
		var rb = result.collider as RigidBody3D
		if rb:
			held_object = rb
			hold_distance = camera.global_transform.origin.distance_to(result.position)
			held_object.freeze = true

func _drop_object():
	if held_object:
		held_object.freeze = false
		held_object = null

func _unhandled_input(event: InputEvent) -> void:

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()

	if can_hold and Input.is_action_just_pressed(input_hold):
		if held_object:
			_drop_object()
		else:
			_try_pickup()
		return
		
	if held_object and Input.is_action_just_pressed(input_throw):
		throw_start = Time.get_ticks_msec()
		return
		
	if held_object and Input.is_action_just_released(input_throw):		
		throw_end = Time.get_ticks_msec()
		throw_direction = -camera.global_transform.basis.z
		throw_amount = throw_maxpower * (((throw_end - throw_start) * 0.001 ) / throw_maxtime)
		throw_object = held_object
		_drop_object()		
		throw_object.apply_impulse(throw_direction * throw_amount)
		return
	
	if Input.is_action_just_pressed("reset"): 
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	
	if can_hold:
		if held_object:
			var target_pos = camera.global_transform.origin + camera.global_transform.basis.z * -hold_distance
			var new_pos = held_object.global_transform.origin.lerp(target_pos, HOLD_SMOOTHNESS * delta)
			held_object.global_transform.origin = new_pos
			held_object.global_transform.basis = camera.global_transform.basis
	
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta
	
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity
	
	if can_sprint and Input.is_action_pressed(input_sprint):
			move_speed = sprint_speed
	else:
		move_speed = base_speed
	
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()

func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed * 0.1
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed * 0.1
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO
func disable_freefly():
	collider.disabled = false
	freeflying = false
func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true
func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false
	if can_hold and not InputMap.has_action(input_hold):
		push_error("Hold disabled. No InputAction found for input_hold: " + input_hold)
		can_hold = false
