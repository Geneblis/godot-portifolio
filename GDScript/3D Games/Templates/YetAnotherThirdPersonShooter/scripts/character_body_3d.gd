extends CharacterBody3D

const SAVE_FILE = "user://idk_shithead.ini"
const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("save"):
		save()
	if Input.is_action_just_pressed("load"):
		_load()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("A", "D", "W", "S")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func save():
	var cfg = ConfigFile.new()
	
	var information_dictionary := []
	information_dictionary.append({
		"stuff": "very important stuff",
		"moare stuff": [1,2,3]
	})
	cfg.set_value("important", "conglomarate_of_sheet", information_dictionary)
	cfg.set_value("PlayerStats", "Health", 100)
	cfg.set_value("PlayerStats", "Psyche", 35)
	var JoeMamamStats := []
	JoeMamamStats.append({
		#Health = 5,
		#Psyche = 10
		
		#funciona igual no lugar do : mas a engine ja converte para 2 pontos.
		"Health": 5,
		"Psyche": 10
	})
	
	#isso daq é insanamente improdutivo se vc n REALMENTE necessita q seje um array.
	cfg.set_value("JoeStats", "Stats", JoeMamamStats)
	
	#exemplo de algo absurdo.
	
	#var AbsurdoDic = []
	#AbsurdoDic.append({
	#	"Alguma": ["dale","32"],
	#	"Coisa": [1,2,3,54,6,7,8,8,99,13,1234,5], "loucura boy",
	#	"Doida": ,
	#	"Tipo",
	#	"Muito",
	#	"Louca"
	#					#vc pegou a ideia....
	#})
	#Imagina rodar tudo isso dentro de um array só pra pegar, por exemplo, a quinta valor do chave "Louca"
	#É um array muito grande, iria demorar muito. Um exemplo bom q isso pd ser util seria uma tabela com
	
	#section Inimigos e cada chave seria os inimigos daquele level, ainda assim, seria mlhr fzr dessa forma:
	#section Inimigos, Inimigo1_Vida=Dados, Inimigo1_Força=Dado1 ...  
	
	
	cfg.save(SAVE_FILE)
	print("saved!")

func _load():
	var cfg = ConfigFile.new()
	var config = cfg.load(SAVE_FILE)
	
	#pegando dados de uma chave direto
	#seção > chave > valor

	var pHealth = cfg.get_value("PlayerStats", "Health")
	print(pHealth)

	#pegando dados de um array ou dicionário
	var player_name = cfg.get_value("important", "conglomarate_of_sheet", [])
	for i in player_name:
		#vai dentro de player_name e pega o valor da chave "stuff"
		var f = i.get("stuff")
		print(f)
		
	var joe = cfg.get_value("JoeStats", "Stats", [])
	for i in joe:
		#vai dentro de player_name e pega o valor da chave "stuff"
		var f = i.get("Health")
		print(f)
