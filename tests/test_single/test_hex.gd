extends GutTest

#-----------------------------------------------------------------#
var line: AreaLine


func before_each():
	ignore_method_when_doubling(AreaLine, '_to_string')
	ignore_method_when_doubling(AreaRing, '_to_string')


func test_line_init():
	line = partial_double(AreaLine).new()
	line.start = Vector2i.ZERO
	line.end = Vector2i.ZERO
	assert_coords(line, [Vector2i(0, 0)])


func test_line_rotate():
	line = partial_double(AreaLine).new()
	line.start = Vector2i(0, 0)
	line.end = Vector2i(2, 0)

	var a0 = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	var a1 = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)]

	assert_coords(line, a0)
	_test_rotate(line, +1, 1, a1, true)
	_test_rotate(line, -1, 5, a0, true)

#-----------------------------------------------------------------#
var ring: AreaRing


func test_ring_init():
	ring = partial_double(AreaRing).new()
	ring.radius = 1
	var expected = [
		Vector2i(0, -1),
		Vector2i(-1, 0),
		Vector2i(-1, 1),
		Vector2i(0, 1),
		Vector2i(1, 0),
		Vector2i(1, -1),
	]
	assert_coords(ring, expected)


func assert_coords(area: Area, array: Array):
	var a = area.get_coords().keys()
	a.sort()
	array.sort()
	assert_eq(a, array)


func _test_rotate(area: Area, degree: int, actual_degree: int, a: Array, update_request := false):
	area.rotate(degree)
	assert_called(area._rotate.bind(actual_degree)) # gdlint-ignore
	if update_request:
		assert_called(area.request_update)
	assert_called(area._get_shape) # gdlint-ignore
	assert_eq(area.start, a[0])
	assert_eq(area.end, a[-1])
	assert_coords(area, a)
