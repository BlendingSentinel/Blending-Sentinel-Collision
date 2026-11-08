@tool
extends EditorScenePostImport

const PREFIX = "BSC_"
const BOX_PREFIX = "BSC_BOX_"
const TRIMESH_PREFIX = "BSC_TRIMESH_"

func _post_import(scene: Node) -> Object:
	_process_node(scene, scene)
	return scene

func _process_node(node: Node, scene_root: Node) -> void:
	if node is MeshInstance3D:
		# CRITICAL: Only process nodes that explicitly start with "BSC_"
		if node.name.begins_with(PREFIX):
			if node.name.begins_with(BOX_PREFIX):
				_convert_to_box(node, scene_root)
				return
			elif node.name.begins_with(TRIMESH_PREFIX):
				_convert_to_trimesh(node, scene_root)
				return
			elif _is_hollow_mesh(node.name):
				_convert_to_trimesh(node, scene_root)
				return
			else:
				_auto_detect_and_convert(node, scene_root)
				return

	# Recursively check children for BSC_ prefix
	for child in node.get_children():
		_process_node(child, scene_root)

# --- 1. BOX PRIMITIVE ---
func _convert_to_box(mesh_node: MeshInstance3D, scene_root: Node) -> void:
	var mesh = mesh_node.mesh
	if not mesh: return

	var static_body = StaticBody3D.new()
	static_body.name = mesh_node.name.trim_prefix(BOX_PREFIX) + "_Col"
	static_body.transform = mesh_node.transform

	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	var aabb = mesh.get_aabb()
	box_shape.size = aabb.size
	collision_shape.shape = box_shape
	collision_shape.transform.origin = aabb.get_center()

	print("BSC: [Box Primitive] Generated for ", mesh_node.name)
	_finalize_collision(mesh_node, static_body, collision_shape, scene_root)

# --- 2. TRIMESH / CONCAVE ---
func _convert_to_trimesh(mesh_node: MeshInstance3D, scene_root: Node) -> void:
	var mesh = mesh_node.mesh
	if not mesh: return

	var static_body = StaticBody3D.new()
	var clean_name = mesh_node.name
	for p in [TRIMESH_PREFIX, PREFIX]:
		clean_name = clean_name.trim_prefix(p)
		
	static_body.name = clean_name + "_Col"
	static_body.transform = mesh_node.transform

	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = mesh.create_trimesh_shape()

	print("BSC: [Trimesh/Concave] Generated hollow shape for ", mesh_node.name)
	_finalize_collision(mesh_node, static_body, collision_shape, scene_root)

# --- 3. AUTO-DETECT CONVEX ---
func _auto_detect_and_convert(mesh_node: MeshInstance3D, scene_root: Node) -> void:
	var mesh = mesh_node.mesh
	if not mesh: return

	var static_body = StaticBody3D.new()
	static_body.name = mesh_node.name.trim_prefix(PREFIX) + "_Col"
	static_body.transform = mesh_node.transform

	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = mesh.create_convex_shape(true, true)

	print("BSC: [Convex] Solid hull generated for ", mesh_node.name)
	_finalize_collision(mesh_node, static_body, collision_shape, scene_root)

# --- Keyword Filter for Hollow Objects (Only runs on BSC_ items) ---
func _is_hollow_mesh(node_name: String) -> bool:
	var lower = node_name.to_lower()
	if "doorway" in lower or "arch" in lower or "cave" in lower or "tunnel" in lower or "room" in lower:
		return true
	return false

func _finalize_collision(mesh_node: MeshInstance3D, static_body: StaticBody3D, collision_shape: CollisionShape3D, scene_root: Node) -> void:
	var parent = mesh_node.get_parent()
	if parent:
		parent.add_child(static_body)
		static_body.owner = scene_root
		
		static_body.add_child(collision_shape)
		collision_shape.owner = scene_root
		
		mesh_node.queue_free()
