extends Node2D

const SURFACE_HEIGHT = 36
const CURVE_POINT_DISTANCE = 24
const CHUNK_SIZE = 16
const MAX_ACTIVE_CHUNKS = 8 # This squared is the final amount of chunks, make it a multiple of 2 pretty please
const TILE_SIZE = 8

var edited_chunks = {} # -> [chunk_pos][tile_pos][properties]
var recently_updated = []


func edit_tile(pos : Vector2, new_tile = -1):
	var multiply_value = TILE_SIZE * CHUNK_SIZE / 2
	# global coords
	var chunk_pos = Vector2(snapped(pos.x - multiply_value, TILE_SIZE * CHUNK_SIZE), snapped(pos.y - multiply_value, TILE_SIZE * CHUNK_SIZE))
	# tile coords
	var tile_pos = Vector2(snapped(pos.x - TILE_SIZE / 2, TILE_SIZE) / TILE_SIZE, snapped(pos.y - TILE_SIZE / 2, TILE_SIZE) / TILE_SIZE)
	
	if !edited_chunks.has(chunk_pos):
		edited_chunks[chunk_pos] = {tile_pos : [new_tile]}
	else:
		edited_chunks[chunk_pos][tile_pos] = [new_tile]
	
	recently_updated.append([tile_pos, new_tile])
