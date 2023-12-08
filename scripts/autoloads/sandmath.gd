extends Node2D


func biased_randi_range(from : int, to : int, bias_towards : int, bias_intensity = 0, number_seed = 0):
	seed(number_seed)
	var current_closest_result = randi_range(from, to)
	for i in bias_intensity:
		seed(number_seed + (i + 1))
		var new_result = randi_range(from, to)
		if abs(new_result - bias_towards) < (current_closest_result - bias_towards):
			current_closest_result = new_result
	return current_closest_result


func biased_randf_range(from : float, to : float, bias_towards : float, bias_intensity = 0, number_seed = 0):
	seed(number_seed)
	var current_closest_result = randf_range(from, to)
	for i in bias_intensity:
		seed(number_seed + (i + 1))
		var new_result = randf_range(from, to)
		if abs(new_result - bias_towards) < (current_closest_result - bias_towards):
			current_closest_result = new_result
	return current_closest_result
