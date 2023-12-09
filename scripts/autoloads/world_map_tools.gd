extends Node2D

const SURFACE_HEIGHT = 36
const CURVE_POINT_DISTANCE = 24
const CHUNK_SIZE = 16
const MAX_ACTIVE_CHUNKS = 6 # This squared is the final amount of chunks
const TILE_SIZE = 8

var edited_chunks = {} # -> chunk pos : [[tile_pos1, tile_id1], [tile_pos2, tile_id_2]...], TO BE CHANGED FROM ARRAY TO DICTIONARY
var recently_updated = []


func edit_tile(pos : Vector2, new_tile = -1):
	# NOTE: these are in the tilemap coordinate system, so divided by tile size
	var chunk_pos = Vector2(snapped(pos.x, TILE_SIZE * CHUNK_SIZE) / TILE_SIZE, snapped(pos.y, TILE_SIZE * CHUNK_SIZE) / TILE_SIZE)
	var tile_pos = Vector2(snapped(pos.x, TILE_SIZE) / TILE_SIZE, snapped(pos.y, TILE_SIZE) / TILE_SIZE)
	
	if !edited_chunks.has(chunk_pos):
		edited_chunks[chunk_pos] = {tile_pos : [new_tile]}
	else:
		edited_chunks[chunk_pos][tile_pos] = [new_tile]
	
	recently_updated.append([tile_pos, new_tile])
