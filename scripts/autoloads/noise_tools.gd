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
