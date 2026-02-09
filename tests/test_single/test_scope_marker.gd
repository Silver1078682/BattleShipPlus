extends GutTestGame

var TYPES = [ScopeMarker, ScopeMarkerArea, ScopeMarkerProperty]


func before_each():
	ignore_method_when_doubling(ScopeMarker, '_to_string')
	ignore_method_when_doubling(ScopeMarkerArea, '_to_string')
	ignore_method_when_doubling(ScopeMarkerArea, 'get_area')
	ignore_method_when_doubling(ScopeMarkerProperty, '_to_string')


const COORDS = [Vector2i.ZERO, Vector2i.ONE]


func test_basic() -> void:
	for coord in COORDS:
		var scpmk: ScopeMarker = partial_double(ScopeMarker).new()
		scpmk.start(null, coord)
		assert_called(scpmk.mark_map_layer.bind(coord))
		scpmk.end()
		assert_called(scpmk.unmark_map_layer)


func test_area():
	for coord in COORDS:
		var scpmk := ScopeMarkerArea.new()
		var area := AreaHex.new()
		area.radius = 2
		scpmk.area = area
		assert_eq(scpmk.get_coords(), area.get_coords())

		scpmk.map_layer = Map.Layer.ACTION_LAYER
		scpmk.start(null, coord)
		assert_eq(scpmk.get_coords(), Map.instance.action_layer)
		scpmk.end()
