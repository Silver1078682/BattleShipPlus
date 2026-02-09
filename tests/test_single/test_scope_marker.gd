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
		assert_called(scpmk._mark_map_layer)
		scpmk.end()
		assert_called(scpmk._unmark_map_layer)


func test_area():
	for coord in COORDS:
		var scpmk := ScopeMarkerArea.new()
		var area := AreaHex.new()
		area.radius = 2
		scpmk.area = area
		assert_eq(scpmk.get_coords(), area.get_coords())

		var map_layers = {
			Map.Layer.ACTION_LAYER: Map.instance.action_layer,
			Map.Layer.ATTACK_LAYER: Map.instance.attack_layer,
			Map.Layer.AERIAL_DEFENSE_LAYER: Map.instance.aerial_defense_layer,
		}
		for map_layer_id in map_layers:
			var map_layer = map_layers[map_layer_id]
			scpmk.map_layer = map_layer_id
			scpmk.start(null, coord)
			assert_eq(scpmk.get_coords(), map_layer.get_coords())
			scpmk.end()
