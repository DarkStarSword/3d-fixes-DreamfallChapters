Texture2D<float> font : register(t100);
Texture2D<float4> StereoParams : register(t125);

static const float font_scale = 1.0;
static float2 cur_pos;
static float4 resolution;
static float2 char_size;
static int2 meta_pos_start;

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

struct vs2gs {
	uint idx : TEXCOORD0;
};

struct gs2ps {
	float4 pos : SV_Position0;
	float2 tex : TEXCOORD1;
	uint character : TEXCOORD2;
};

void get_meta()
{
	float font_width, font_height;

	resolution = StereoParams.Load(int3(2, 0, 0));

	font.GetDimensions(font_width, font_height);
	char_size = float2(font_width, font_height) / float2(16, 6);

	meta_pos_start = float2(15 * char_size.x, 5 * char_size.y);
}

float2 get_char_dimensions(uint c)
{
	float2 meta_pos;
	float2 dim;

	meta_pos.x = meta_pos_start.x + (c % 16);
	meta_pos.y = meta_pos_start.y + (c / 16 - 2) * 2;

	dim.x = font.Load(int3(meta_pos, 0)) * 255;
	meta_pos.y++;
	dim.y = font.Load(int3(meta_pos, 0)) * 255;

	return dim;
}

void emit_char(uint c, inout TriangleStream<gs2ps> ostream)
{
	if (c > ' ' && c < 0x7f) {
		gs2ps output;
		// Not taking specific character width into account for simplicity.
		// Could save some pixels by doing so, but who cares?
		float2 dim = char_size / resolution.xy * 2 * font_scale;

		output.character = c;

		output.pos = float4(cur_pos.x        , cur_pos.y - dim.y, 0, 1);
		output.tex = float2(0, 1);
		ostream.Append(output);
		output.pos = float4(cur_pos.x + dim.x, cur_pos.y - dim.y, 0, 1);
		output.tex = float2(1, 1);
		ostream.Append(output);
		output.pos = float4(cur_pos.x        , cur_pos.y        , 0, 1);
		output.tex = float2(0, 0);
		ostream.Append(output);
		output.pos = float4(cur_pos.x + dim.x, cur_pos.y        , 0, 1);
		output.tex = float2(1, 0);
		ostream.Append(output);

		ostream.RestartStrip();
	}

	// Increment current position taking specific character width into account:
	float2 cdim = get_char_dimensions(c);
	cur_pos.x += cdim.x / resolution.x * 2 * font_scale;
}

void emit_int(int val, inout TriangleStream<gs2ps> ostream)
{
	int digit;

	if (val < 0.0) {
		emit_char('-', ostream);
		val *= -1;
	}

	int e = 0;
	if (val == 0) {
		emit_char('0', ostream);
		return;
	}
	e = log10(val);
	while (e >= 0) {
		digit = int(val / pow(10, e)) % 10;
		emit_char(digit + 0x30, ostream);
		e--;
	}
}

void emit_float(float val, inout TriangleStream<gs2ps> ostream)
{
	int digit;
	int significant = 0;
	int scientific = 0;

	if (isnan(val)) {
		emit_char('N', ostream);
		emit_char('a', ostream);
		emit_char('N', ostream);
		return;
	}

	if (val < 0.0) {
		emit_char('-', ostream);
		val *= -1;
	}

	if (isinf(val)) {
		emit_char('i', ostream);
		emit_char('n', ostream);
		emit_char('f', ostream);
		return;
	}

	if (val == 0) {
		emit_char('0', ostream);
		return;
	}

	int e = log10(val);
	if (e < 0) {
		emit_char('0', ostream);
	} else {
		if (e > 6)
			scientific = e;
		while (e - scientific >= 0) {
			digit = int(val / pow(10, e)) % 10;
			emit_char(digit + 0x30, ostream);
			if (digit || significant) // Don't count leading 0 as significant, but do count following 0s
				significant++;
			e--;
		}
	}
	if (!scientific && frac(val / pow(10, e + 1)) == 0)
		return;
	emit_char('.', ostream);
	bool emitted = false;
	while (!emitted || (significant < 6 && frac(val / pow(10, e + 1)))) {
		digit = int(val / pow(10, e)) % 10;
		emit_char(digit + 0x30, ostream);
		significant++;
		e--;
		emitted = true;
	}

	if (scientific) {
		emit_char('e', ostream);
		emit_int(scientific, ostream);
	}
}

// The max here is dictated by 1024 / sizeof(gs2ps)
[maxvertexcount(144)]
void main(point vs2gs input[1], inout TriangleStream<gs2ps> ostream)
{
	get_meta();
	uint idx = input[0].idx;
	float char_height = char_size.y / resolution.y * 2 * font_scale;
	int max_y = resolution.y / char_size.y * font_scale;

	cur_pos = float2(-1 + (idx / max_y * 0.32), 1 - (idx % max_y) * char_height);
	if (cur_pos.x >= 1)
		return;

	uint output_char1 = ' ';
	uint output_char2 = ' ';
	float3 output_float = 0;

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

	// Reducing complexity that depends on flow control - not because I
	// care about performance on the GPU, but because the compiler takes
	// exponentially longer the more flow control is used.
	uint n = 3;
	if (idx <= n++) {
		// Vector2(0, 0), new Vector2(1, 0), new Vector2(1, 1), new Vector2(0, 1)};
		output_char1 = idx == 1 || idx == 2 ? '1' : '0';
		output_char2 = idx >= 2 ? '1' : '0';
		output_float = _FrustumRays[idx];
	} else if (idx == n++) {
		output_char1 = 'F'; output_char2 = 'A';
		output_float = float3(_FrustumApex, 0, 0);
	} else if (idx == n++) {
		output_char1 = 'L'; output_char2 = 'S';
		output_float = _LightPos;
	} else if (idx == n++) {
		output_char1 = 'C'; output_char2 = 'L';
		output_float = _CameraPosLocal;
	} else if (idx == n++) {
		output_char1 = 'C'; output_char2 = 'W';
		output_float = _WorldSpaceCameraPos;
	} else if (idx == n++) {
		output_char1 = 'C'; output_char2 = 'S';
		output_float = _CameraPosLocal * (_ProjectionParams.z / far_local);
	} else if (idx == n++) {
		output_char1 = 'F';
		output_float = float3(far_local, _ProjectionParams.z, _ProjectionParams.z / far_local);
	} else if (idx == n++) {
		output_char1 = 'L';
		output_char2 = 'X';
		output_float = local_light_pos_1;
	} else if (idx == n++) {
		output_char1 = 'L';
		output_char2 = 'Y';
		output_float = local_light_pos_2;
	} else if (idx == n++) {
		output_char1 = 'L';
		output_char2 = 'D';
		output_float = local_light_pos_2 - local_light_pos_1;
	} else if (idx == n++) {
		output_char1 = 'L';
		output_char2 = 'C';
		output_float = local_light_pos_to_camera;
	} else if (idx == n++) {
		output_char1 = 'D';
		output_char2 = 'W';
		output_float = float3(light_depth_world, 0, 0);
	}

	emit_char(output_char1, ostream);
	emit_char(output_char2, ostream);
	emit_char(' ', ostream);
	emit_float(output_float.x, ostream);
	emit_char(' ', ostream);
	emit_float(output_float.y, ostream);
	emit_char(' ', ostream);
	emit_float(output_float.z, ostream);
}
