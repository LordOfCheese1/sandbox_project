extends Node2D

# it'd be cool if everything here is a multiple of 2, thanks
const SURFACE_HEIGHT : int = 36
const CURVE_POINT_DISTANCE : int = 24
const CHUNK_SIZE : int = 16
const MAX_ACTIVE_CHUNKS : int = 8 # This squared is the final amount of chunks
const TILE_SIZE : int = 8

var edited_chunks = {} # -> [chunk_pos][tile_pos][properties]
var recently_updated = []


func edit_tile(pos : Vector2, new_tile = -1):
	var multiply_value = (TILE_SIZE * CHUNK_SIZE) * 0.5
	# global coords
	var chunk_pos = Vector2(snapped(pos.x - multiply_value, TILE_SIZE * CHUNK_SIZE), snapped(pos.y - multiply_value, TILE_SIZE * CHUNK_SIZE))
	# tile coords
	var tile_pos = Vector2(snapped(pos.x - TILE_SIZE * 0.5, TILE_SIZE) / TILE_SIZE, snapped(pos.y - TILE_SIZE * 0.5, TILE_SIZE) / TILE_SIZE)
	
	if !edited_chunks.has(chunk_pos):
		edited_chunks[chunk_pos] = {tile_pos : [new_tile]}
	else:
		edited_chunks[chunk_pos][tile_pos] = [new_tile]
	
	recently_updated.append([tile_pos, new_tile])


func get_used_chunks_by_structure(structure_pos : Vector2i, structure_data = {}):
	var used_chunks = []


func get_structure_data(structure_name : String):
	var file = FileAccess.open("res://structure_tile_data.json", FileAccess.READ)
	var raw_data = JSON.parse_string(file.get_as_text())
	
	var tile_data = {}
	for key in raw_data[structure_name].keys():
		tile_data[str_to_vector(key)] = raw_data[structure_name][key]
	
	return tile_data


func str_to_vector(input : String):
	var x = ""
	var y = ""
	var y_reached = false
	for c in input:
		if c != ",":
			if y_reached:
				y = y + c
			else:
				x = x + c
		else:
			y_reached = true
	return Vector2i(int(x), int(y))


func vector_to_str(input : Vector2):
	return str(input.x) + "," + str(input.y)
