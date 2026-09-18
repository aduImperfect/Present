class_name InteractiveAudioArea3D
extends Area3D

@export var default_audio_stream: AudioStream
@export var audio_stream: AudioStream
@export var target_scene_pack: PackedScene = null
@export var require_input_action: String = "view_information" # E.g., 'e' or interact key

var player_inside: bool = false
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	audio_player.stream = default_audio_stream

func _unhandled_input(event: InputEvent) -> void:
	if player_inside and audio_stream and require_input_action != "" and event.is_action_pressed(require_input_action):
		audio_player.stop()
		audio_player.playing = false
		audio_player.stream = audio_stream
		trigger_interaction()
	elif player_inside and !audio_player.playing and !event.is_action_pressed(require_input_action):
		audio_player.stream = default_audio_stream
		trigger_interaction()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		print("Player entered interaction zone.")

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = false

# Call this from a button or input trigger
func trigger_interaction() -> void:
	if audio_player.playing:
		return

	audio_player.stop()
	if audio_player and audio_player.stream:
		audio_player.play()
	
	if target_scene_pack:
		await get_tree().create_timer(0.2).timeout # short delay for sound start optionally
		get_tree().change_scene_to_packed(target_scene_pack)
