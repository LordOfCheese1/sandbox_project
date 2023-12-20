extends Node2D

@export var structure_name : String


func _ready():
	var structure_data = {}
	for tile in $tiles.get_used_cells(0):
		structure_data[tile] = $tiles.get_cell_atlas_coords(0, tile)
	
	var file = FileAccess.open("res://structure_tile_data.json", FileAccess.READ_WRITE)
	var data_file = JSON.parse_string(file.get_as_text())
	
	for i in structure_data.keys():
		if !data_file.has(structure_name):
			data_file[structure_name] = {}
		data_file[structure_name][WorldMapTools.vector_to_str(i)] = structure_data[i]
	
	file.store_string(JSON.stringify(data_file))
	file.close()
