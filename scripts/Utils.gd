extends Node

var world
var nickname


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
