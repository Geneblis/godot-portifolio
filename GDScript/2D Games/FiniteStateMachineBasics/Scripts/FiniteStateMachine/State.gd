##NOTE: This will be used as an abstract class for all FSM states. Not meant to be directly used.
@icon("res://icon.svg") ##Use a better one.
extends Node
class_name State
signal Transition

func Enter(): #enter a state
	pass
	
func Exit(): #exit a state
	pass
	
func Update(_delta: float): #change the state
	pass
	
func Physics_Update(_delta: float): #check the state
	pass
