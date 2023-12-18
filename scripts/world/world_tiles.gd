extends TileMap

# Rules in here: When referring to chunks, the coordinates are ALWAYS global, whereas tiles must always be in the tilemap coordinate system(/tile size)
var creation_queue = []
var active_chunks = [] # this uses the chunk origin, so top left
var deletion_queue = []


func _ready():
	pass


func _process(_delta):
	get_chunks_around_player()
	
	# find chunks that are too far away, add to deletion queue
	for chunk in active_chunks:
		var required_dst = WorldMapTools.TILE_SIZE * WorldMapTools.CHUNK_SIZE * WorldMapTools.MAX_ACTIVE_CHUNKS
		if abs(chunk.x - Globals.player_pos.x) > required_dst || abs(chunk.y - Globals.player_pos.y) > required_dst:
			queue_chunk_deletion(chunk)
			active_chunks.erase(chunk)
	
	# done every frame instead of a loop due to performance reasons
	# create chunk from the queue
	if len(creation_queue) > 0:
		if !active_chunks.has(creation_queue[0]):
			generate_chunk(creation_queue[0])
			active_chunks.append(creation_queue[0])
		creation_queue.remove_at(0)
	# delete chunk from the queue
	if len(deletion_queue) > 0:
		delete_chunk(deletion_queue[0])
		deletion_queue.remove_at(0)
	
	# place all tiles that were edited just now
	for tile in WorldMapTools.recently_updated:
		set_cell(0, tile[0], 0, Vector2(tile[1], 0), 0)
	WorldMapTools.recently_updated = []


func get_chunks_around_player():
	for x in WorldMapTools.MAX_ACTIVE_CHUNKS:
		for y in WorldMapTools.MAX_ACTIVE_CHUNKS:
			var snapped_player_x = snapped(Globals.player_pos.x - WorldMapTools.CHUNK_SIZE * WorldMapTools.TILE_SIZE * 0.5, WorldMapTools.CHUNK_SIZE * WorldMapTools.TILE_SIZE)
			var snapped_player_y = snapped(Globals.player_pos.y - WorldMapTools.CHUNK_SIZE * WorldMapTools.TILE_SIZE * 0.5, WorldMapTools.CHUNK_SIZE * WorldMapTools.TILE_SIZE)
			var chunk = Vector2(snapped_player_x, snapped_player_y) + Vector2(x - WorldMapTools.MAX_ACTIVE_CHUNKS * 0.5, y - WorldMapTools.MAX_ACTIVE_CHUNKS * 0.5) * WorldMapTools.TILE_SIZE * WorldMapTools.CHUNK_SIZE
			if !creation_queue.has(chunk) && !active_chunks.has(chunk):
				queue_chunk_creation(chunk)


func queue_chunk_creation(pos : Vector2):
	creation_queue.append(pos)


func queue_chunk_deletion(pos : Vector2):
	deletion_queue.append(pos)


func generate_chunk(pos : Vector2): # global coords
	# loop through all tiles of the chunk
	for x in WorldMapTools.CHUNK_SIZE:
		for y in WorldMapTools.CHUNK_SIZE:
			var tile_pos = (pos / WorldMapTools.TILE_SIZE) + Vector2(x, y)
			# do the checks and place tiles accordingly
			do_checks(tile_pos)
	apply_edits_in_chunk(pos)


func apply_edits_in_chunk(chunk_pos : Vector2):
	if WorldMapTools.edited_chunks.has(chunk_pos):
		for tile_pos in WorldMapTools.edited_chunks[chunk_pos]:
			set_cell(0, tile_pos, 0, Vector2(WorldMapTools.edited_chunks[chunk_pos][tile_pos][0], 0), 0)


func delete_chunk(pos : Vector2): # global coords
	for x in WorldMapTools.CHUNK_SIZE:
		for y in WorldMapTools.CHUNK_SIZE:
			set_cell(0, pos / WorldMapTools.TILE_SIZE + Vector2(x, y), 0, Vector2(-1, -1), 0)


func do_checks(pos : Vector2): # tile coords
	var tile_to_place = -1
	
	# min height, max height, bias towards, bias intensity, surface tile, underground tile
	
	if pos.y > curve_surface_check(pos):
		if abs(pos.y - curve_surface_check(pos)) < 1.5:
			tile_to_place = 2
		else:
			tile_to_place = 5
	
	set_cell(0, pos, 0, Vector2(tile_to_place, 0), 0)


func curve_surface_check(pos : Vector2):
	# basically just subtracting the leftover from x so it's snapped to the point to its left
	var start_x = pos.x - fmod(pos.x, WorldMapTools.CURVE_POINT_DISTANCE)
	
	# adding constant distance then subtracting the leftover to get the point to the right
	var end_x = pos.x + WorldMapTools.CURVE_POINT_DISTANCE - fmod(pos.x, WorldMapTools.CURVE_POINT_DISTANCE)
	
	# get the current transition of x from start(0) to finish(1), i.e. from 16 to 32, if x was 24, 0.5 would be returned, inverted if x < 0
	var transition_value = (start_x - pos.x) / WorldMapTools.CURVE_POINT_DISTANCE
	if pos.x < 0:
		transition_value = 1 - transition_value
	
	# get the cosine-interpolated y value based on start-height, end-height and the transition value
	return cerp(generate_y_height_for_x(start_x), generate_y_height_for_x(end_x), transition_value)


func generate_y_height_for_x(x : float, min_height = -20, max_height = 20, bias = 0, bias_intensity = 5):
	return SandMath.biased_randi_range(WorldMapTools.SURFACE_HEIGHT + min_height, WorldMapTools.SURFACE_HEIGHT + max_height, bias, bias_intensity, x + Globals.world_seed)


func cerp(a, b, transition_value : float): # transition value ranges from 0 to 1
	var interp_value = (1 - cos(transition_value * PI)) * 0.5
	return lerp(a, b, interp_value)
