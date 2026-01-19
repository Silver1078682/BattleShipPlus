extends Tester

func _run() -> void:
	Log.debug("testing AreaLine")
	## create
	var line := AreaLine.new()
	## modify
	line.start = Vector2i.ZERO
	line.end = Vector2i.ZERO
	## check
	check_area(line, [Vector2i(0, 0)])

	# Test a line from (0,0) to (2,2)
	line.start = Vector2i(0, 0)
	line.end = Vector2i(2, 2)
	var expected = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
	check_area(line, expected)

	# Test a horizontal line from (0,0) to (2,0)
	line.start = Vector2i(0, 0)
	line.end = Vector2i(2, 0)
	expected = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	check_area(line, expected)

	Log.debug("testing AreaRing")
	## create
	var ring := AreaRing.new()
	## modify
	ring.radius = 1
	## check
	expected = [
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(-1, 1),
		Vector2i(0, 1),
		Vector2i(1, 0),
		Vector2i(1, -1),
	]
	check_area(ring, expected)


#-----------------------------------------------------------------#
func _check_area(area: Area, desired_coords: Array) -> bool:
	var hash_table: Dictionary
	for i in desired_coords:
		hash_table[i] = 1

	var shape := area.get_shape()
	for coord in shape:
		if hash_table.get(coord) == null:
			Log.error("Unexpected coordinate %s in shape" % [coord])
			return false

	for coord in hash_table:
		if shape.get(coord) == null:
			Log.error("Missing coordinate %s in shape" % [coord])
			return false
	return true


func check_area(area: Area, desired_coords: Array):
	if not _check_area(area, desired_coords):
		Log.error("AreaLine test failed with area %s and coords %s" % [area, desired_coords])
