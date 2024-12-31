@tool
extends EditorPlugin
var button
var target_node
func _enter_tree() -> void:
	button = Button.new()
	button.text = "property"
	button.pressed.connect(_button_clicked)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR,button)
	button.get_parent().move_child(button,4)


func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR,button)

func _button_clicked():
	var sr = EditorInterface.get_selection()
	var selected_arr = sr.get_selected_nodes()
	if selected_arr != null and !selected_arr.is_empty():
		target_node = selected_arr[0]
		var property_selector = PropertySelectionWindow.new()
		property_selector.create_window(selected_arr[0],[],false,-1,_on_properties_selected)

func initial_value(target_node, p):
	var v = PropertySelectionWindow._get_property_safely(target_node, p.name)
	if v == null:
		return "null"
	elif v is Resource:
		return "preload(\"%s\")" % (v as Resource).resource_path
	else:
		return var_to_str(v)

func _on_properties_selected(selected_properties: Array[String]):
	var plist = (target_node as Node).get_property_list()
	plist = plist.filter(func(x):return selected_properties.has(x.name))
	print(plist)
	var root = EditorInterface.get_edited_scene_root()
	print(root.scene_file_path)
	print(root.get_script().resource_path)
	print(root.get_script().resource_name)
	if target_node == root:
		print("cant be same node!")
		return
	var part_a = node_format.format({
		"arg_node":target_node.name.to_snake_case(),
		"arg_node_path":root.get_path_to(target_node)
	})
	var part_b = ""
	var target_property_in_ready_dic = {}
	for p in plist:
		if not (target_node.name.to_snake_case() + "_" + p.name) in root:
			part_b = part_b + property_format.format({
				"arg_node":target_node.name.to_snake_case(),
				"arg_name":target_node.name.to_snake_case() + "_" + p.name,
				"prop_name":p.name,
				"arg_type":type_string(p.type) if (p.class_name == null \
					or p.class_name.is_empty()) else p.class_name.split(",")[0],
				"arg_initial_value": initial_value(target_node, p)
			})
			target_property_in_ready_dic[(target_node.name.to_snake_case() + "_" + p.name)] = false
	
	var origin_source = root.get_script().source_code
	var origin_lines = origin_source.split("\n")
	var output_lines = []
	var in_ready = false
	for line in origin_lines:
		output_lines.append(line)
		if line.strip_edges().begins_with("func _ready"):
			in_ready = true
		elif in_ready and not line.begins_with("\t"):
			# If we encounter an empty line while in _ready, assume the end of the function
			in_ready = false
		elif in_ready:
			for k in target_property_in_ready_dic.keys():
				if line.strip_edges().begins_with("self.{arg_name} = {arg_name}".format({"arg_name":k})):
					target_property_in_ready_dic[k] = true
				if line.strip_edges().begins_with("{arg_name} = {arg_name}".format({"arg_name":k})):
					target_property_in_ready_dic[k] = true
	var inserted_lines = []
	for k in target_property_in_ready_dic.keys():
		if !target_property_in_ready_dic[k]:
			inserted_lines.append("\tself.{arg_name} = {arg_name}".format({"arg_name":k}))
	for i in range(len(output_lines)):
		if output_lines[i].strip_edges().begins_with("func _ready"):
			for x in inserted_lines:
				output_lines.insert(i + 1, x)
			break
	
	var f = FileAccess.open(root.get_script().resource_path,FileAccess.READ_WRITE)
	if not target_node.name.to_snake_case() in root:
		output_lines.append(part_a)
	output_lines.append(part_b)
	
	var output_text = "\n".join(output_lines)
	print(output_text)
	f.store_string(output_text)
	f.close()
	
	var efs = EditorInterface.get_resource_filesystem()
	efs.update_file(root.get_script().resource_path)
	efs.scan()
	root.get_script().reload(true)
	root.get_script().source_code = output_text
	
	var xi = -1
	for x in EditorInterface.get_script_editor().get_open_scripts():
		xi += 1
		if x.resource_path == root.get_script().resource_path:
			var ce = EditorInterface.get_script_editor().get_open_script_editors()[xi]
			if ce.get_base_editor() is CodeEdit:
				(ce.get_base_editor() as CodeEdit).text = output_text

var node_format:String = "
@onready var {arg_node} = ${arg_node_path}
"
var property_format:String = "
@export var {arg_name}:{arg_type} = {arg_initial_value}:
	set(v):
		{arg_name} = v
		if is_instance_valid({arg_node}):
			{arg_node}.set(\"{prop_name}\",{arg_name})
"
