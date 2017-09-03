Texture2D<float4> StereoParams : register(t125);
Texture1D<float4> IniParams : register(t120);
#ifndef separation
#define separation StereoParams.Load(0).x
#endif
#ifndef convergence
#define convergence StereoParams.Load(0).y
#endif
#ifndef eye
#define eye StereoParams.Load(0).z
#endif

cbuffer Globals : register(b13) {
  float4  _LightPos           : packoffset(c6);
  matrix  _FrustumRays        : packoffset(c8);
  float4  _CameraPosLocal     : packoffset(c12);
  float   _FrustumApex        : packoffset(c13);
  float4  _CoordTexDim        : packoffset(c14);
//float4  _ShadowmapDim       : packoffset(c14); // Overlap
  float4  _ScreenTexDim       : packoffset(c15);
//float   _DepthThreshold     : packoffset(c16); // Overlap
  float4  _LightColor         : packoffset(c16);
  float   _Extinction         : packoffset(c17);
  float   _Brightness         : packoffset(c17.y);
  float   _MinDistFromCamera  : packoffset(c17.z);
}
struct Globals {
  float4  UNUSED_0_5[6];
  float4  _LightPos           ; // packoffset(c6)
  float4  UNUSED_7;
  matrix  _FrustumRays        ; // packoffset(c8)
  float4  _CameraPosLocal     ; // packoffset(c12)
  float   _FrustumApex        ; // packoffset(c13)
  float3  UNUSED_13_YZW;
  float4  _CoordTexDim        ; // packoffset(c14)
//float4  _ShadowmapDim       ; // packoffset(c14) // Overlap
  float4  _ScreenTexDim       ; // packoffset(c15)
//float   _DepthThreshold     ; // packoffset(c16) // Overlap
  float4  _LightColor         ; // packoffset(c16)
  float   _Extinction         ; // packoffset(c17)
  float   _Brightness         ; // packoffset(c17.y)
  float   _MinDistFromCamera  ; // packoffset(c17.z)
};

static float4 stereo_LightPos = _LightPos;
static matrix stereo_FrustumRays = _FrustumRays;
static float4 stereo_CameraPosLocal = _CameraPosLocal;

static matrix world_FrustumRays;
static float local_far;
static float world_far;
static float3 local_to_world_scale;
static float4 local_cam_axis[3];
static float3 local_light_pos;

// Copied from lighting shaders with 3DMigoto, definition from
// CGIncludes/UnityShaderVariables.cginc:
cbuffer UnityPerCamera : register(b11)
{
	// Time (t = time since current level load) values from Unity
	uniform float4 _Time; // (t/20, t, t*2, t*3)
	uniform float4 _SinTime; // sin(t/8), sin(t/4), sin(t/2), sin(t)
	uniform float4 _CosTime; // cos(t/8), cos(t/4), cos(t/2), cos(t)
	uniform float4 unity_DeltaTime; // dt, 1/dt, smoothdt, 1/smoothdt

	uniform float3 _WorldSpaceCameraPos;

	// x = 1 or -1 (-1 if projection is flipped)
	// y = near plane
	// z = far plane
	// w = 1/far plane
	uniform float4 _ProjectionParams;

	// x = width
	// y = height
	// z = 1 + 1.0/width
	// w = 1 + 1.0/height
	uniform float4 _ScreenParams;

	// Values used to linearize the Z buffer (http://www.humus.name/temp/Linearize%20depth.txt)
	// x = 1-far/near
	// y = far/near
	// z = x/far
	// w = y/far
	uniform float4 _ZBufferParams;

	// x = orthographic camera's width
	// y = orthographic camera's height
	// z = unused
	// w = 1.0 if camera is ortho, 0.0 if perspective
	uniform float4 unity_OrthoParams;
}

cbuffer Resource_Inverse_VP_CB : register(b10)
{
	matrix I_VP;
}

void stereoise_light_shaft_parameters()
{
	float3 tmp1;
	float3 tmp2;
	float3 tmp3;

	// Create our own set of frustum coordinates in world space:
	float2 corners[4] = {float2(-1, -1), float2(1, -1), float2(1, 1), float2(-1, 1)};
	for (uint i = 0; i < 4; i++) {
		world_FrustumRays[i] = float4(corners[i], 1, 1);
		world_FrustumRays[i] = mul(I_VP, world_FrustumRays[i]);
		world_FrustumRays[i] /= world_FrustumRays[i].w;
		world_FrustumRays[i].xyz -= _WorldSpaceCameraPos.xyz;
	}

	// Find the far clipping plane in local coords:
	tmp3 = lerp(_FrustumRays[0].xyz, _FrustumRays[2].xyz, 0.5);
	local_far = distance(tmp3, 0);

	// Camera axis in local coordinates:
	local_cam_axis[0] = float4(normalize(_FrustumRays[1].xyz - _FrustumRays[0].xyz), 0);
	local_cam_axis[1] = float4(normalize(_FrustumRays[3].xyz - _FrustumRays[0].xyz), 0);
	local_cam_axis[2] = float4(normalize(tmp3), 0);

	// Find far clipping plane in world coords:
	//tmp3 = lerp(world_FrustumRays[0].xyz, world_FrustumRays[2].xyz, 0.5);
	//world_far = distance(tmp3, 0);
	// Alternatively, just use the value from Unity:
	world_far = _ProjectionParams.z;

	// Use the local + world frustums to calculate the X & Y scaling, and
	// the derived far clipping plane in local & world to calculate Z:
	local_to_world_scale.x = distance(world_FrustumRays[1], world_FrustumRays[0]) /
				 distance(_FrustumRays[1], _FrustumRays[0]);
	local_to_world_scale.y = distance(world_FrustumRays[1], world_FrustumRays[0]) /
				 distance(_FrustumRays[1], _FrustumRays[0]);
	local_to_world_scale.z = world_far / local_far;

	// Project the light position onto the far clipping plane.
	// Note that the order of the frustum is not what you might expect:
	// Vector2(0, 0), new Vector2(1, 0), new Vector2(1, 1), new Vector2(0, 1)};
	tmp1 = lerp(_FrustumRays[0].xyz, _FrustumRays[1].xyz, _LightPos.x / 2 + 0.5);
	tmp2 = lerp(_FrustumRays[3].xyz, _FrustumRays[2].xyz, _LightPos.x / 2 + 0.5);
	tmp3 = lerp(tmp1, tmp2, _LightPos.y / 2 + 0.5);

	float3 local_light_pos_projected_on_far = tmp3 + _CameraPosLocal.xyz;
	float3 local_light_direction = tmp3;

	// The light position in local coordinates is somewhere along the line
	// between _CameraPosLocal and local_light_pos_projected_on_far

	// Formula of a line:
	// (x - x1) / l = (y - y1) / m = (z - z1) / n
	// We can plug _CameraPosLocal in as (x1, y1, z1) and local_light_direction as (l, m, n)

	// We need to find the light position. Assume that it will fall along
	// that line where the local coords are x = y = 0, z = ?
	// We should be able to use either of these two formulas to find it z,
	// and comparing the results should give us a good idea if our maths
	// and assumptions are correct. The result should also be constant,
	// independent of the camera position:
	// z = (((x - x1) * n / l) + z1);
	// z = (((y - y1) * n / m) + z1);
	// z = -x1 * n / l + z1;
	// z = -y1 * n / m + z1;
	float3 local_light_pos_1 = float3(0, 0, -_CameraPosLocal.x * local_light_direction.z / local_light_direction.x + _CameraPosLocal.z);
	float3 local_light_pos_2 = float3(0, 0, -_CameraPosLocal.y * local_light_direction.z / local_light_direction.y + _CameraPosLocal.z);
	local_light_pos = local_light_pos_1;

	// The value we are calculating is very close to this value - is it this?
	// local_light_pos = float3(0, 0, _FrustumApex);

	// Get the light position relative to the camera, still in local coords:
	float3 local_light_pos_to_camera = local_light_pos - _CameraPosLocal;

	// Get the light Z depth from the camera, still in local coords:
	float light_depth_local = dot(local_light_pos_to_camera, local_cam_axis[2].xyz);

	// Now scale using the camera far plane compared to our computed far plane:
	float light_depth_world = light_depth_local * local_to_world_scale.z;

	// Finally, derive the stereo adjustment amount for the light:
	stereo_LightPos.x += separation * (light_depth_world - convergence) / light_depth_world;
	// The debug visualisation shader needs to do a depth >= 0 test:
	stereo_LightPos.w = light_depth_world;

	// Calculate the amount we need to adjust the camera position by in local space:
	float cam_adj = -separation * convergence;
	float4 cam_adj_ws_vec = mul(I_VP, float4(cam_adj, 0, 0, 0));
	float cam_adj_ws_mag = distance(cam_adj_ws_vec, 0);

	stereo_CameraPosLocal.xyz -= local_cam_axis[0].xyz * sign(cam_adj) * cam_adj_ws_mag / local_to_world_scale.x;

	// Calculate the amount we need to adjust the camera frustum by in local space:
	float frustum_adj = separation * (_ProjectionParams.z - convergence);
	float4 frustum_adj_ws_vec = mul(I_VP, float4(frustum_adj, 0, 0, 0));
	float frustum_adj_ws_mag = distance(frustum_adj_ws_vec, 0);
	float3 frustum_adj_local = local_cam_axis[0].xyz * sign(frustum_adj) * frustum_adj_ws_mag / local_to_world_scale.x;

	for (uint i = 0; i < 4; i++)
		stereo_FrustumRays[i].xyz -= frustum_adj_local;
}
