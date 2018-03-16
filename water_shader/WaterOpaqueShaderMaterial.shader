// Shader to simulate an open ocean based on Gerstner waves
// Reference: https://developer.nvidia.com/gpugems/GPUGems/gpugems_ch01.html

shader_type spatial;

render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo: hint_color;
uniform sampler2D texture_albedo: hint_albedo;

uniform bool albedo_wave_enabled;

uniform bool foam_enabled;
uniform sampler2D texture_foam: hint_albedo;

uniform float specular : hint_range(0.0, 1.0);
uniform float roughness : hint_range(0.0, 1.0);
uniform float metallic : hint_range(0.0, 1.0);


uniform bool world_triplanar;
uniform float uv_blend_sharpness;
uniform vec3 uv_tri_scale;
uniform vec3 uv_tri_offset;

uniform bool vertex_waves_enabled;
uniform bool vertex_displace_from_mesh_normal;
uniform bool normal_displace_from_mesh_normal;

uniform bool debug_time_invariant; // ZA WARUDO! Toki wo tomare.

// Wave values are numbered since Godot's shading language does not support arrays yet

// Values for wave 1; Wave 1 is the "base" wave, the biggest one. Foam uses this.
uniform float 	Steepness1 = .5;
uniform float 	Amplitude1 = .1;
uniform vec2 	Direction1 = vec2(1.0, 0.0);
uniform float 	Frequency1 = 0.2;
uniform float 	Speed1 	   = 1.5;

// Values for wave 2; this is a detail wave.
uniform float 	Steepness2 = .1;
uniform float 	Amplitude2 = .2;
uniform vec2 	Direction2 = vec2(0.784436, -0.62021);
uniform float 	Frequency2 = 0.6;
uniform float 	Speed2 	   = 2;

// Values for wave 3; this is a detail wave.
uniform float 	Steepness3 = .1;
uniform float 	Amplitude3 = .1;
uniform vec2 	Direction3 = vec2(0.210012, -0.977699);
uniform float 	Frequency3 = 0.2;
uniform float 	Speed3 	   = 1.5;

// Values for wave 4; Wave 4 is the second biggest wave, plays off of wave 1. Foam uses this.
uniform float 	Steepness4 = .2;
uniform float 	Amplitude4 = .1;
uniform vec2 	Direction4 = vec2(-0.680626, -0.732631);
uniform float 	Frequency4 = 0.3;
uniform float 	Speed4 	   = 1;

// Values for wave 5; this was supposed to be the high frequency detail wave, but I couldn't stand the moire patterns.
uniform float 	Steepness5 = .2;
uniform float 	Amplitude5 = .2;
uniform vec2 	Direction5 = vec2(-0.998566, -0.053534);
uniform float 	Frequency5 = 0.25;
uniform float 	Speed5 	   = 1;

varying vec3	uv_tri;
varying vec3	refraction_uv_tri;
varying vec3	uv_power_normal;
varying float	foam_alpha;

// An offset at a point on a Gerstner Wave
/*
 * x & z: wave position
 * t: time
 * Steepness: physical height of the wave. Up and down particle motion.
 * Amplitude: also height, but affects the normal more. Fore and aft particle motion.
 * Direction, Frequency, Speed: self explanatory
 */
vec3 P(float x, float z, float t, float Steepness, float Amplitude, vec2 Direction, float Frequency, float Speed) {
	float twopi = 6.283185307179586;
	vec3 result;
	result.x = ((Steepness * Amplitude) * Direction.x * cos(twopi * dot(Frequency * Direction, vec2(x, z)) + (Speed * t)));
	result.y = Steepness * sin(twopi * dot(Frequency * Direction, vec2(x, z)) + (Speed * t));
	result.z = ((Steepness * Amplitude) * Direction.y * cos(twopi * dot(Frequency * Direction, vec2(x, z)) + (Speed * t)));
	
	return result;
}

// Normal at a given point
vec3 N(float x, float z, float t, float Steepness, float Amplitude, vec2 Direction, float Frequency, float Speed) {
	float twopi = 6.283185307179586;
	vec3 result;
	result.x = (-1.0) * (Direction.x * Frequency * Amplitude * (cos((Frequency * twopi * dot(Direction, vec2(x, z))) + Speed * t)));
	result.y = 1.0 - (Steepness * Frequency * Amplitude * sin((Frequency * twopi * dot(Direction, vec2(x, z))) + Speed * t));
	result.z = (-1.0) * (Direction.y * Frequency * Amplitude * (cos((Frequency * twopi * dot(Direction, vec2(x, z))) + Speed * t)));
	
	return result;
}

// Rotate a vector from vec3(0,1,0) to the normal, rotation about the z and y axes.
vec3 rotate_to_normal(vec3 point, vec3 normal)
{
	float theta = atan(normal.z, normal.x);
	float phi = acos(normal.y);
	float ct = cos(theta);
	float st = sin(theta);
	float cp = cos(phi);
	float sp = sin(phi);
	// column major. okay, deep breaths. I got this.
//	mat3 rot = mat3( vec3(cp*ct, sp*ct,-st), vec3(-sp,cp,0), vec3(cp*st,sp*st,ct));
	// huh. let's try row major instead. okay I guess that works?
	mat3 rot = mat3( vec3(cp*ct, -sp, cp*st), vec3(sp*ct, cp, sp*st), vec3(-st, 0, ct));
	vec3 newpoint = rot*point;
	return newpoint;
}

void vertex() {
	float time = TIME; //TIME;
	if (debug_time_invariant)
	{
		time = 1.0;
	}
	
	// UV will be assigned based on xz world coords
	vec2 wave_coords = VERTEX.xz;
	if (world_triplanar)
	{
		vec4 world_coordinates = WORLD_MATRIX * vec4(VERTEX,1);
		
		// Define triplanar UV
		uv_power_normal=pow(abs(NORMAL),vec3(uv_blend_sharpness));
		uv_power_normal/=dot(uv_power_normal,vec3(1.0));
		uv_tri = (world_coordinates).xyz / uv_tri_scale + uv_tri_offset;
		uv_tri *= vec3(1.0,-1.0, 1.0);
	
		// Keep UV based on world XZ around as inputs to various wave functions
		wave_coords = world_coordinates.xz;
		UV = uv_tri.xz;
	}
	
	// Apply some wavey movement to the general UV coords
	if (albedo_wave_enabled)
	{
		// Throw in a bunch of constants to make these VERTEX waves look good in UV space
		vec3 uvwave;
		if (world_triplanar)
		{ 
			// We can take any frequencies and direction since we're not worried about texture seaming
			uvwave= P(UV.x, UV.y, time, Steepness2 * 0.1, Amplitude2 * 1.0, Direction2, Frequency2 * 15.0, Speed2 * 0.25);
			uvwave += P(UV.x, UV.y, time, Steepness3 * 0.1, Amplitude3 * 1.0, Direction3, Frequency3 * 15.0, Speed3 * 0.25);
			uv_tri += uvwave;
		}
		else
		{
			// Fix direction and round frequency to respect texture wrapping on spherical meshes
			uvwave = P(UV.x, UV.y, time, Steepness2 * 0.1, Amplitude2 * 1.0, vec2(1.0,1.0), round(Frequency2 * 15.0), Speed2 * 0.25);
			uvwave += P(UV.x, UV.y, time, Steepness3 * 0.1, Amplitude3 * 1.0, vec2(1.0,-1.0), round(Frequency3 * 15.0), Speed3 * 0.25);
		}
		UV += uvwave.xz;
	}
	
	// Apply some constant movement 
	if (world_triplanar)
	{
		refraction_uv_tri = uv_tri;
		refraction_uv_tri += vec3(0.1, -0.2, -0.15) * time;
	
		uv_tri += vec3(0.1) * time;
	}
	
	UV += vec2(0.1)* time;
	
	// Calcualte foam alpha here where it's cheaper
	foam_alpha = 1.0;
	if (foam_enabled)
	{
		// Throw in a bunch of constants to make these VERTEX waves look good in UV space
		vec3 vertexWave1 = P(UV.x, UV.y, time, Steepness1, Amplitude1, Direction1, Frequency1 * 15.0, Speed1 * 0.25);
		vec3 vertexWave4 = P(UV.x, UV.y, time, Steepness4, Amplitude4, Direction4, Frequency4 * 15.0, Speed4 * 0.25);
		vec3 vertexWave = ((vertexWave1 + vertexWave4) / 2.0) - 0.5;
		foam_alpha = vertexWave.y;
	}
	
	if (vertex_waves_enabled)
	{
		// Calculate offset for every wave, take average
		vec3 vertexWave1 = P(wave_coords.x, wave_coords.y, time, Steepness1, Amplitude1, Direction1, Frequency1, Speed1);
		vec3 vertexWave2 = P(wave_coords.x, wave_coords.y, time, Steepness2, Amplitude2, Direction2, Frequency2, Speed2);
		vec3 vertexWave3 = P(wave_coords.x, wave_coords.y, time, Steepness3, Amplitude3, Direction3, Frequency3, Speed3);
		vec3 vertexWave4 = P(wave_coords.x, wave_coords.y, time, Steepness4, Amplitude4, Direction4, Frequency4, Speed4);
		vec3 vertexWave5 = P(wave_coords.x, wave_coords.y, time, Steepness5, Amplitude5, Direction5, Frequency5, Speed5);
		vec3 vertexWaveFinal = (vertexWave1 + vertexWave2 + vertexWave3 + vertexWave4 + vertexWave5) / 5.0;
		
		if (vertex_displace_from_mesh_normal)
		{
			vertexWaveFinal = rotate_to_normal(vertexWaveFinal, NORMAL);
		}
		VERTEX += vertexWaveFinal;
	}
	// Calculate normal for each wave, take average
	vec3 normalWave1 = N(wave_coords.x, wave_coords.y, time, Steepness1, Amplitude1, Direction1, Frequency1, Speed1);
	vec3 normalWave2 = N(wave_coords.x, wave_coords.y, time, Steepness2, Amplitude2, Direction2, Frequency2, Speed2);
	vec3 normalWave3 = N(wave_coords.x, wave_coords.y, time, Steepness3, Amplitude3, Direction3, Frequency3, Speed3);
	vec3 normalWave4 = N(wave_coords.x, wave_coords.y, time, Steepness3, Amplitude4, Direction4, Frequency4, Speed4);
	vec3 normalWave5 = N(wave_coords.x, wave_coords.y, time, Steepness3, Amplitude5, Direction5, Frequency5, Speed5);
	vec3 normalWaveFinal = (normalWave1 + normalWave2 + normalWave3 + normalWave4 + normalWave5) / 5.0;
	if (normal_displace_from_mesh_normal)
	{
		normalWaveFinal = rotate_to_normal(normalWaveFinal, NORMAL);
	}
	NORMAL = normalize(normalWaveFinal);
	
}

vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

void fragment() {
	float rtot = 0.7071067811865476; // root two over two
	
	float time = TIME; //TIME;
	if (debug_time_invariant)
	{
		time = 1.0;
	}
	
	SPECULAR = specular;
	ROUGHNESS = roughness;
	
	
	vec4 albedo_tex;
	if (world_triplanar)
	{
		albedo_tex = triplanar_texture(texture_albedo, uv_power_normal, uv_tri);
	}
	else
	{
		albedo_tex = texture(texture_albedo, UV);
	}
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	
	/* Sea Foam
	 * override refraction and add to albedo
	 * scale foam opacity by height of a few of the vertex waves. 
	 */
	if (foam_enabled)
	{
		vec4 foam_tex;
		if (world_triplanar)
		{
			foam_tex = triplanar_texture(texture_foam, uv_power_normal, uv_tri)  * clamp(foam_alpha, 0.0, 1.0);
		}
		else
		{
			foam_tex = texture(texture_foam, UV) * clamp(foam_alpha, 0.0, 1.0);
		}
		EMISSION *= (1.0-foam_tex.a); // block emission
		ALBEDO = ALBEDO*(1.0-foam_tex.a) + foam_tex.rgb*foam_tex.a; // overwrite albedo
	}
	
	
}