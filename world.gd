extends Node3D

const extra_hight = .2

const WATER_BASE_HEIGHT = .2 + extra_hight;
const WATER_CHARACTER = "~";
const WATER_COLOR = Color8(173,251,253,1);

const MOUNTAIN_BASE_HEIGHT = 1.5 + extra_hight;
const MOUNTAIN_MULTIPLIER = 1.5 + extra_hight;
const MOUNTAIN_CHARACTER = "^";
const MOUNTAIN_COLOR = Color8(253,191,150,1);

const PIT_BASE_HEIGHT = 0.2 + extra_hight;
const PIT_MULTIPLIER = 0.5;
const PIT_CHARACTER = "#";
const PIT_COLOR = Color8(0,0,0,1);

const MINERAL_BASE_HEIGHT = 1 + extra_hight;
const MINERAL_CHARACTER = "*";
const MINERAL_COLOR = Color8(170, 221, 119, 1);

const GROUND_BASE_HEIGHT = 1 + extra_hight;
const GROUND_COLOR = Color8(253,105,95,1);

@onready var ground = load("res://assets/Ground.tscn");
@onready var container = $BlockContainer;

var random = RandomNumberGenerator.new();

@export var rotation_speed = 1;
var container_offset_x = 0;
var container_offset_y = 0;

func _process(delta):
	container.rotate_object_local(Vector3.UP, rotation_speed * delta);

func _on_file_dialog_file_selected(path):
	delete_children(container);
	var lines = read_selected_file(path);
	container_offset_x = len(lines[0]) / 2;
	container_offset_y = len(lines) / 2;
	container.translate(Vector3(0,0,0));
	var map_matrix = parse_lines_to_map_matrix(lines);
	var height_matrix = create_hight_matrix(map_matrix);
	generate_blocks(map_matrix, height_matrix);
	
	
func read_selected_file(path):
	var file = FileAccess.open(path, FileAccess.READ);
	var content = file.get_as_text();
	var lines = content.split("\n");
	return lines;

func parse_lines_to_map_matrix(lines):
	var matrix = []
	for i in range(len(lines)):
		matrix.append([])
		var line_chars = lines[i].split('');
		for j in range(len(line_chars)):
			matrix[i].append(line_chars[j]);
	return matrix;
	
func create_hight_matrix(map_matrix):
	var matrix = []
	for i in range(len(map_matrix)):
		matrix.append([])
		for j in range(len(map_matrix[0])):
			var current = map_matrix[i][j];
			if current == MOUNTAIN_CHARACTER:
				matrix[i].append(calculate_mountain_height(map_matrix, i, j, MOUNTAIN_CHARACTER));
			elif current == PIT_CHARACTER:
				matrix[i].append(calculate_pit_height(map_matrix, i, j, PIT_CHARACTER));
			elif current == WATER_CHARACTER:
				matrix[i].append(calculate_water_height(map_matrix, i, j));
			elif current == MINERAL_CHARACTER:
				matrix[i].append(calculate_mineral_height(map_matrix, i, j));
			else:
				matrix[i].append(GROUND_BASE_HEIGHT * (random.randf() - .2));
	
	return matrix;

func generate_blocks(map_matrix, height_matrix):
	for i in range(len(map_matrix)):
		for j in range(len(map_matrix[i])):
			var g = ground.instantiate();
			container.add_child(g);
			g.translate(Vector3(i - container_offset_x, 0, j-container_offset_y));
			g.set_scale(Vector3(1, height_matrix[i][j] ,1));
			g.transform
			var material = StandardMaterial3D.new();
			if map_matrix[i][j] == MOUNTAIN_CHARACTER:
				material.albedo_color = MOUNTAIN_COLOR;
				g.get_node("MeshInstance3D").set_surface_override_material(0, material);
			elif map_matrix[i][j] == PIT_CHARACTER:
				material.albedo_color = PIT_COLOR;
				g.get_node("MeshInstance3D").set_surface_override_material(0, material);
			elif map_matrix[i][j] == WATER_CHARACTER:
				material.albedo_color = WATER_COLOR;
				g.get_node("MeshInstance3D").set_surface_override_material(0, material);
			elif map_matrix[i][j] == MINERAL_CHARACTER:
				material.albedo_color = MINERAL_COLOR;
				g.get_node("MeshInstance3D").set_surface_override_material(0, material);
			else:
				material.albedo_color = GROUND_COLOR;
				g.get_node("MeshInstance3D").set_surface_override_material(0, material);


func calculate_mountain_height(map_matrix, i, j, map_char):
	var height = MOUNTAIN_BASE_HEIGHT;
	var neighbour_count = 0;
	if (map_matrix[i+1][j] == map_char):
		neighbour_count += 1;
	if (map_matrix[i-1][j] == map_char):
		neighbour_count += 1;
	if (map_matrix[i][j+1] == map_char):
		neighbour_count =+ 1;
	if (map_matrix[i][j-1] == map_char):
		neighbour_count =+ 1;
		
	return height + MOUNTAIN_MULTIPLIER * neighbour_count;
func calculate_pit_height(map_matrix, i, j, map_char):
	var height = PIT_BASE_HEIGHT;
	if (map_matrix[i+1][j] == map_char):
		height *= PIT_MULTIPLIER;
	if (map_matrix[i-1][j] == map_char):
		height *= PIT_MULTIPLIER;
	if (map_matrix[i][j+1] == map_char):
		height *= PIT_MULTIPLIER;
	if (map_matrix[i][j-1] == map_char):
		height *= PIT_MULTIPLIER;
		
	return height;
func calculate_water_height(map_matrix, i, j):
	var height = WATER_BASE_HEIGHT;
	return height;
func calculate_mineral_height(map_matrix, i, j):
	return MINERAL_BASE_HEIGHT;


func _on_h_slider_value_changed(value):
	rotation_speed = value;

func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()
