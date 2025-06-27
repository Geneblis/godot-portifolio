extends Node2D

#region Constants
const CELL_EMPTY = ""
const CELL_X = "X"
const CELL_O = "O"
#endregion

#region Node References
@onready var buttons = $GridContainer.get_children()
@onready var label   = $Menu/Label
@onready var menu    = $Menu
#endregion

#region Game State
var current_player
var board
#endregion

#region Lifecycle
func _ready() -> void:
	label.text = ""
	var button_index = 0
	for button in buttons:
		button.connect("pressed", _on_button_click.bind(button_index, button))
		button_index += 1
	reset_game()
#endregion

#region Input Handling
func _on_button_click(idx, button):
	var y = idx / 3
	var x = idx % 3
	button.text = current_player
	if board[x][y] == CELL_EMPTY:
		board[x][y] = current_player
		if check_win():
			label.text = current_player + " has won!"
			reset_game()
		elif check_fullboard():
			label.text = "It's a Draw!"
			reset_game()
		else:
			current_player = CELL_X if current_player == CELL_O else CELL_O
#endregion

#region Win / Draw Checks
func check_win() -> bool:
	for i in range(3):
		if board[i][0] == board[i][1] and board[i][1] == board[i][2] and board[i][2] != CELL_EMPTY:
			return true
		if board[0][i] == board[1][i] and board[1][i] == board[2][i] and board[2][i] != CELL_EMPTY:
			return true
	if board[0][0] == board[1][1] and board[1][1] == board[2][2] and board[2][2] != CELL_EMPTY:
		return true
	if board[2][0] == board[1][1] and board[1][1] == board[0][2] and board[0][2] != CELL_EMPTY:
		return true
	return false

func check_fullboard() -> bool:
	for row in board:
		for col in row:
			if col == CELL_EMPTY:
				return false
	return true
#endregion

#region Game Control
func reset_game() -> void:
	current_player = CELL_X
	board = [
		[CELL_EMPTY, CELL_EMPTY, CELL_EMPTY],
		[CELL_EMPTY, CELL_EMPTY, CELL_EMPTY],
		[CELL_EMPTY, CELL_EMPTY, CELL_EMPTY],
	]
	for button in buttons:
		button.text = CELL_EMPTY
	menu.show()

func _on_button_pressed() -> void:
	label.text = ""
	menu.hide()
#endregion
