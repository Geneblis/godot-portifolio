# Base class for defining an individual behavior state.
# Inherit from State and override the following callbacks:
#   Enter()         — Called once when the state becomes active.
#   Exit()          — Called once when the state is about to be deactivated.
#   Update(delta)   — Called every frame for non-physics logic.
#   Physics_Update(delta) — Called every physics frame for movement, collisions, etc.
extends Node
class_name State

func Enter():
    pass

func Exit():
    pass

func Update(_delta: float):
    pass

func Physics_Update(_delta: float):
    pass
