extends Node3D

#TODO Signals aren't firing
#TODO Might need to make a group or something
func _on_area_3d_body_entered(body: Node3D):
	EventsManager.emit_signal("safe_volume_entered", body)

func _on_area_3d_body_exited(body: Node3D):
	EventsManager.emit_signal("safe_volume_exited", body)
