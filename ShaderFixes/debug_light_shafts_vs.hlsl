Texture2D<float4> StereoParams : register(t125);
#define separation StereoParams.Load(0).x
#define convergence StereoParams.Load(0).y
Texture1D<float4> IniParams : register(t120);

cbuffer globals : register(b13) {
	float4 _LightPos : packoffset(c6);
	matrix _FrustumRays : packoffset(c8);
	float4 _CameraPosLocal : packoffset(c12);
	float _FrustumApex : packoffset(c13);
	float4 _CoordTexDim : packoffset(c14);
	float4 _ScreenTexDim : packoffset(c15);
};

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

void main(
		out float4 pos : SV_Position0,
		uint vertex : SV_VertexID)
{
	pos.xy = _LightPos.xy;
	pos.y *= -1;

	// Not using vertex buffers so manufacture our own coordinates.
	switch(vertex) {
		case 0:
			pos.xy += float2(-0.005, -0.005);
			break;
		case 1:
			pos.xy += float2(-0.005, 0.005);
			break;
		case 2:
			pos.xy += float2(0.005, -0.005);
			break;
		case 3:
			pos.xy += float2(0.005, 0.005);
			break;
		default:
			pos.xy = 0;
			break;
	};
	pos.zw = float2(0, 1);

	float3 tmp1;
	float3 tmp2;
	float3 tmp3;

	// Find far clipping plane in local coords:
	tmp3 = lerp(_FrustumRays[0].xyz, _FrustumRays[2].xyz, 0.5);
	float3 cam_dir = normalize(tmp3);
	float far_local = distance(tmp3, 0);
	float scale_to_world = _ProjectionParams.z / far_local;

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
	float3 local_light_pos = local_light_pos_1;

	// The value we are calculating is very close to this value - is it this?
	// local_light_pos = float3(0, 0, _FrustumApex);

	// Get the light position relative to the camera, still in local coords:
	float3 local_light_pos_to_camera = local_light_pos - _CameraPosLocal;

	// Get the light Z depth from the camera, still in local coords:
	float light_depth_local = dot(local_light_pos_to_camera, cam_dir) / distance(cam_dir, 0);

	// Now scale using the camera far plane compared to our computed far plane:
	float light_depth_world = light_depth_local * scale_to_world;

	float depth = light_depth_world;

	if (IniParams[7].y)
		pos.x += separation * (depth - convergence) / depth;
	if (depth <= 0)
		pos = 0;
}
