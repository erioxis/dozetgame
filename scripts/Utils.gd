extends Node

var world
var nickname

var resp = preload("res://Scenes/respawn.tscn")
var damage = preload("res://Scenes/damage.tscn")

enum TOOLTYPE
{
	TOOL,
	GUN,
	OTHER
}

enum WHO
{
	PLAYER,
	ZOMBIE
}

func dropDice(num: int):
	if (randi()%num+1==num):
		return true
	else:
		return false
		
const LANGUAGE = [
	{"oa_bl":"оаоаао"},
	{"HihiHaha":"Хихи хаха"},
	{"Teleporting to sigil":"Телепортация к сигилу"} #Создашь отдельный файлик под языки,ок?
] #И лучше юзать нижние названия для id(для веса)|ХОТЯ МОЖНО ТИПО {"Bla bla bla bla: "Бла бла бла бла"}
func translate_get(id):
	for j in range(0,LANGUAGE.size()):
		#print(LANGUAGE[j].get(id))
		if LANGUAGE[j].get(id) is String: #можешь возвращать оригинальный если инглиш,базу я +- подготовил
			return LANGUAGE[j].get(id)
	return "@"+id+"@"

func respawn(id, who:Utils.WHO, t):
	var r = resp.instantiate()
	world.add_child(r, true)
	r.init(int(str(id)), who, t)

@rpc("call_local", "any_peer", "reliable")
func create_damage(dmg, pos):
	var d = damage.instantiate()
	world.add_child(d , true)
	d.global_position = pos
	d.set_label(dmg)
	
func push(target:RigidBody3D, where:Vector3):
	target.apply_central_impulse(where)
