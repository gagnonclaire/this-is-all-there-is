extends Node3D

#TODO Signals aren't firing
#TODO Might need to make agroup or something
func _on_area_3d_body_entered(_body):
	EventsManager.emit_signal("safe_volume_entered")

func _on_area_3d_body_exited(_body):
	EventsManager.emit_signal("safe_volume_exited")
