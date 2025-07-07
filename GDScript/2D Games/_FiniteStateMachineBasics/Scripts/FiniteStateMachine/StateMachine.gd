##########################################################################################
# StateMachine handler that manages multiple State children on a single parent.
# Usage:
# 1. Add this script to a Node.
# 2. Add one or more State-derived nodes as its children.
# 3. Assign `initial_state` in the inspector to pick the starting state.
# 4. States emit `Transition` (with the new state's name) to switch.
#
# The machine:
#  - Scans its children for State instances on _ready()
#  - Connects to each child's `Transition` signal.
#  - Calls Enter() on the initial state.
#  - Routes each frame to current_state.Update() and current_state.Physics_Update().		
##########################################################################################
extends State
class_name StateMachine

@export var initial_state : State
var current_state: State
var states : Dictionary = {}
signal Transition

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
    if not new_state:
        return
    current_state.Exit()
    new_state.Enter()
    current_state = new_state
