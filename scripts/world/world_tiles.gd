extends TileMap

const SURFACE_HEIGHT = 36
const CURVE_POINT_DISTANCE = 24
const CHUNK_SIZE = 16
const MAX_ACTIVE_CHUNKS = 8 # This squared is the final amount of chunks
const TILE_SIZE = 8

var chunk_queue = []
var active_chunks = [] # this uses the chunk origin, so top left, a chunk is 16*16 tiles or 64*64 pixels
var deletion_queue = []


func _ready():
	clear()


func _process(_delta):
	generate_based_on_playerpos()
	
	var temp_removed_chunk_amt = 0
	
	for i in len(active_chunks):
		var chunk = active_chunks[i - temp_removed_chunk_amt]
		# check if distance to player is higher than max active chunks
		if abs(chunk.x - Globals.player_pos.x) + abs(chunk.y - Globals.player_pos.y) > CHUNK_SIZE * MAX_ACTIVE_CHUNKS * TILE_SIZE: 
			# queue chunk for deletion and remove from active chunks, temp_removed_chunk_amt exists to not reference nonexistent indexes
			queue_chunk_deletion(active_chunks[i- temp_removed_chunk_amt])
			active_chunks.remove_at(i - temp_removed_chunk_amt)
			temp_removed_chunk_amt += 1
	
	# create and delete chunks from the queue
	if len(chunk_queue) > 0:
		generate_chunk_by_pos(chunk_queue[0])
		active_chunks.append(chunk_queue[0])
		chunk_queue.remove_at(0)
	
	if len(deletion_queue) > 0:
		clear_chunk_by_pos(deletion_queue[0])
		deletion_queue.remove_at(0)


func queue_chunk_creation(pos : Vector2):
	chunk_queue.append(pos)


func queue_chunk_deletion(pos : Vector2):
	deletion_queue.append(pos)


func generate_chunk_by_pos(pos : Vector2):
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var real_pos = Vector2(pos.x / TILE_SIZE + x, pos.y / TILE_SIZE + y)
			if real_pos.y > get_curve_surface(real_pos):
				set_cell(0, Vector2(real_pos.x, real_pos.y), 0, Vector2(0, 1), 0)


func clear_chunk_by_pos(pos : Vector2):
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var real_pos = Vector2(pos.x / TILE_SIZE + x, pos.y / TILE_SIZE + y)
			set_cell(0, real_pos, -1, Vector2(-1, -1), -1)


func get_curve_surface(pos : Vector2):
	# basically just subtracting the leftover from x so it's snapped to the point to its left
	var start_x = pos.x - fmod(pos.x, CURVE_POINT_DISTANCE)
	
	# adding constant distance then subtracting the leftover to get the point to the right
	var end_x = pos.x + CURVE_POINT_DISTANCE - fmod(pos.x, CURVE_POINT_DISTANCE)
	
	# get the current transition of x from start(0) to finish(1), i.e. from 16 to 32, if x was 24, 0.5 would be returned, inverted if x < 0
	var transition_value = (start_x - pos.x) / CURVE_POINT_DISTANCE
	if pos.x < 0:
		transition_value = 1 - transition_value
	
	# get the cosine-interpolated y value based on start-height, end-height and the transition value
	return cerp(generate_y_height_for_x(start_x), generate_y_height_for_x(end_x), transition_value) 


func generate_y_height_for_x(x : float):
	return Sandmath.biased_randi_range(SURFACE_HEIGHT - 20, SURFACE_HEIGHT + 20, 0, 4, x + Globals.world_seed)


func cerp(a, b, transition_value : float): # transition value ranges from 0 to 1
	var interp_value = (1 - cos(transition_value * PI)) / 2
	return lerp(a, b, interp_value)


func generate_based_on_playerpos():
	var current_centre = Vector2(snapped(Globals.player_pos.x, CHUNK_SIZE * TILE_SIZE), snapped(Globals.player_pos.y, CHUNK_SIZE * TILE_SIZE)) # snapped to 64 because 16(chunk size) * 4(tile size)
	# go through all possible chunk positions around the player pos
	for x in MAX_ACTIVE_CHUNKS:
		for y in MAX_ACTIVE_CHUNKS:
			var chunk = Vector2(current_centre.x + (x - snapped(MAX_ACTIVE_CHUNKS / 2, 1)) * CHUNK_SIZE * TILE_SIZE, current_centre.y + (y - snapped(MAX_ACTIVE_CHUNKS / 2, 1)) * CHUNK_SIZE * TILE_SIZE)
			# if chunk is not already present, queue creation of that chunk
			if active_chunks.has(chunk) or chunk_queue.has(chunk):
				pass
			else:
				queue_chunk_creation(chunk)
