@tool
extends EditorScript

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var player_node: CharacterBody3D = get_scene()
	var player_skeleton: Skeleton3D = player_node.PlayerSkeleton
