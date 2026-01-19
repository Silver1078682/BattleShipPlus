class_name WarshipCard
extends Card

#-----------------------------------------------------------------#
func _set_up(_action) -> void:
	if not _action is ActionArrange:
		Log.error("An WarshipCard can only accepts Action deriving from ActionArrange")
		return

	super(_action)
