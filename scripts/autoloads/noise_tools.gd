extends Node2D

func generate_1d_noise(length : int, noise_seed = 0, smoothing_intensity = 6):
	var noise = []
	# generate initial non-smoothed noise
	for x in length:
		seed(noise_seed + x)
		noise.append(randf_range(0, 1))
	
	for step in smoothing_intensity:
		var smoothed_noise = []
		for i in len(noise):
			var left = 0.0
			var right = 0.0
			if i - 1 < 0:
				left = noise[len(noise) - 1]
			else:
				left = noise[i - 1]
			if i + 1 > len(noise) - 1:
				right = noise[0]
			else:
				right = noise[i + 1]
			smoothed_noise.append((left + right) / 2)
		noise = smoothed_noise
	
	return noise


func generate_cell_clumps(size : Vector2i, rand_seed = 0, iterations = 4):
	var data = {}
	var surrounding_data = [
		Vector2i(-1, -1),
		Vector2i(0, -1),
		Vector2i(1, -1),
		Vector2i(1, 0),
		Vector2i(1, 1),
		Vector2i(0, 1),
		Vector2i(-1, 1),
		Vector2i(-1, 0),
	]
	# initial completely random cells
	for x in size.x:
		for y in size.y:
			seed(rand_seed + x + y)
			data[Vector2i(x, y)] = randi_range(0, 1)
	
	for i in iterations:
		var new_data = {}
		for pos in data:
			var filled_neighbours = 0
			for a in surrounding_data:
				if data[get_neighbour(pos, a, Vector2(size.x - 1, size.y - 1))] == 1:
					filled_neighbours += 1
			if filled_neighbours < 4:
				new_data[pos] = 0
			else:
				new_data[pos] = 1
		data = new_data
	
	return data


func get_neighbour(pos : Vector2i, adder : Vector2i, size : Vector2i):
	var neighbour = pos + adder
	if neighbour.x > size.x:
		neighbour.x = 0
	if neighbour.x < 0:
		neighbour.x = size.x
	if neighbour.y > size.y:
		neighbour.y = 0
	if neighbour.y < 0:
		neighbour.y = size.y
	return neighbour
