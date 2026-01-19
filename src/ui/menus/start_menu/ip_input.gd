extends LineEdit

@export var invalid_color: Color


func _on_text_changed(new_text: String) -> void:
	var valid_input := new_text.is_valid_ip_address()
	self.modulate = Color.WHITE if valid_input else invalid_color
