extends Node2D

@export var structure_name : String


func _ready():
	var structure_data = {}
	for tile in $tiles.get_used_cells(0):
		structure_data[tile] = $tiles.get_cell_atlas_coords(0, tile)
	
	var file = FileAccess.open("res://structure_tile_data.json", FileAccess.READ_WRITE)
	var data_dictionary = JSON.parse_string(file.get_as_text())
	
	print(structure_data)
	
	# loop through tiles
	for i in structure_data.keys():
		# append structure name to dictionary
		if !data_dictionary.has(structure_name):
			data_dictionary[structure_name] = {}
		
		# get current chunk based on tile, global coords
		var multiply = WorldMapTools.CHUNK_SIZE * WorldMapTools.TILE_SIZE
		var current_chunk = Vector2(snapped(i.x * WorldMapTools.TILE_SIZE - multiply * 0.5, multiply), snapped(i.y * WorldMapTools.TILE_SIZE - multiply * 0.5, multiply))
		
		if !data_dictionary[structure_name].has(WorldMapTools.vector_to_str(current_chunk)):
			data_dictionary[structure_name][WorldMapTools.vector_to_str(current_chunk)] = {}
		
		var tile_pos_relative_to_chunk = Vector2(i.x - current_chunk.x / WorldMapTools.TILE_SIZE, i.y - current_chunk.y / WorldMapTools.TILE_SIZE)
		
		data_dictionary[structure_name][WorldMapTools.vector_to_str(current_chunk)][WorldMapTools.vector_to_str(tile_pos_relative_to_chunk)] = structure_data[i]
	
	file.store_string(JSON.stringify(data_dictionary))
	file.close()
