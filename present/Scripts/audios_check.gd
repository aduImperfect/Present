extends Node

func _ready() -> void:
	var all_players: Array[Node] = find_all_audio_players(get_tree().current_scene)
	print("Found ", all_players.size(), " audio players.")

# Recursively traverses the tree to find AudioStreamPlayer, AudioStreamPlayer2D, and AudioStreamPlayer3D
func find_all_audio_players(root: Node) -> Array[Node]:
	var players: Array[Node] = []
	
	if root is AudioStreamPlayer or root is AudioStreamPlayer2D or root is AudioStreamPlayer3D:
		players.append(root)
		
	for child in root.get_children():
		players.append_array(find_all_audio_players(child))
		
	return players
