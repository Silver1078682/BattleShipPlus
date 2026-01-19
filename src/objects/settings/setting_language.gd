class_name SettingLanguage
extends Setting

func _apply(p_value: String) -> void:
	if p_value == "system":
		var preferred_language = OS.get_locale_language()
		TranslationServer.set_locale(preferred_language)
	else:
		TranslationServer.set_locale(p_value)
