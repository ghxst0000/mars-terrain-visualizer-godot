extends Node3D


@export var color = Color.RED;
@export var BASE_HEIGHT = 1;

func _ready():
	#var material = $MeshInstance3D.get_surface_override_material(0);
	#material.albedo_color = color;
	#$MeshInstance3D.set_surface_override_material(0, material);
	transform.origin.x = 0;
	transform.origin.y = 0;
	transform.origin.z = 0;
	pass;

