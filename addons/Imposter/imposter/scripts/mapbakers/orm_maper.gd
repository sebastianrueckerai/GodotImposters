@tool
extends MapBaker


var normal_material = preload("res://addons/Imposter/imposter/materials/orm_baker.material")

func get_name() -> String:
	return "orm"




func is_dilatated() -> bool:
	return true



func _cleanup_baking_material(material: ShaderMaterial) -> void:
	material.set_shader_parameter("texture_albedo", null)
	material.set_shader_parameter("ao_texture", null)
	material.set_shader_parameter("metallic_texture", null)
	material.set_shader_parameter("roughness_texture", null)
	material.set_shader_parameter("roughness", 1.0)
	material.set_shader_parameter("metallic", 0.0)
	material.set_shader_parameter("use_ao_texture", false)
	material.set_shader_parameter("use_roughness_texture", false)
	material.set_shader_parameter("use_metallic_texture", false)


func _mimic_original_spatial_material(original_mat: BaseMaterial3D, material: ShaderMaterial) -> void:
	material.set_shader_parameter("roughness", original_mat.roughness)
	print("ORG ROUGNH", original_mat.roughness)
	if original_mat.roughness_texture != null:
		print("ROUGH TEX=", original_mat.roughness_texture)
		material.set_shader_parameter("roughness_texture", original_mat.roughness_texture)
		material.set_shader_parameter("roughness_texture_channel", original_mat.roughness_texture_channel)
	
	material.set_shader_parameter("metallic", original_mat.metallic)
	if original_mat.metallic_texture != null:
		print("METALIIC TEX=", original_mat.metallic_texture)
		material.set_shader_parameter("metallic_texture", original_mat.metallic_texture)
		material.set_shader_parameter("metallic_texture_channel", original_mat.metallic_texture_channel)

	if original_mat.ao_enabled:
		print("AO TEX=", original_mat.metallic_texture)
		material.set_shader_parameter("ao_texture", original_mat.ao_texture)
		material.set_shader_parameter("ao_texture_channel", original_mat.ao_texture_channel)
	if original_mat.transparency==BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR:
#	if original_mat.params_use_alpha_scissor:
		material.set_shader_parameter("use_alpha_texture", true)
		material.set_shader_parameter("alpha_scissor_threshold", original_mat.alpha_scissor_threshold)
		material.set_shader_parameter("texture_albedo", original_mat.albedo_texture)


func _mimic_original_shader_material(original_mat: ShaderMaterial, material: ShaderMaterial) -> void:
	material.set_shader_parameter("roughness", original_mat.get_shader_parameter("roughness"))
	var roughness_tex = original_mat.get_shader_parameter("roughness_texture")
	if roughness_tex != null:
		material.set_shader_parameter("roughness_texture", roughness_tex)
		material.set_shader_parameter("roughness_texture_channel", original_mat.get_shader_parameter("roughness_texture"))

	material.set_shader_parameter("metallic", original_mat.get_shader_parameter("metallic"))
	var metallic_tex = original_mat.get_shader_parameter("metallic_texture")
	if metallic_tex != null:
		material.set_shader_parameter("metallic_texture", metallic_tex)
		material.set_shader_parameter("metallic_texture_channel", original_mat.get_shader_parameter("metallic_texture_channel"))

	var ao_tex = original_mat.get_shader_parameter("ao_texture")
	if ao_tex != null:
		material.set_shader_parameter("ao_texture", ao_tex)
		material.set_shader_parameter("ao_texture_channel", original_mat.get_shader_parameter("ao_texture_channel"))

	var alpha_scissors = original_mat.get_shader_parameter("alpha_scissor_threshold")
	var albedo_tex = original_mat.get_shader_parameter("texture_albedo")
	if alpha_scissors != null and float(alpha_scissors) > 0.0 and albedo_tex != null:
		material.set_shader_parameter("use_alpha_texture", true)
		material.set_shader_parameter("texture_albedo", albedo_tex)
		material.set_shader_parameter("alpha_scissor_threshold", alpha_scissors)
	else:
		print("Alpha texture not recognized")


func map_bake(org_material: Material) -> Material:
	_cleanup_baking_material(normal_material)
	var mat_baking = normal_material.duplicate()
	if org_material is BaseMaterial3D:
		_mimic_original_spatial_material(org_material, mat_baking)
	elif org_material is ShaderMaterial:
		_mimic_original_shader_material(org_material, mat_baking)
	else:
		print("Unrecognized material during normal baking")
	return mat_baking
