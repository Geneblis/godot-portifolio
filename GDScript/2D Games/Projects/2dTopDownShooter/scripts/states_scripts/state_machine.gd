##NOTE: This is a State Machine Handler. Meant to be used as an child of an object you want to use it for.
##Add all states as it's child. 
extends Node
class_name State
@export var initial_state : State
var current_state: State
var states : Dictionary = {}
signal Transition

func Enter(): #enter a state
	pass
	
func Exit(): #exit a state
	pass
	
func Update(_delta: float): #change the state
	pass
	
func Physics_Update(_delta: float): #check the state
	pass

#State Machine Handler:
func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transition.connect(on_child_transition)

	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.Exit()
		
	new_state.Enter()
	current_state = new_state
