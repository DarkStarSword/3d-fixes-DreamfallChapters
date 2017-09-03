#include "light_shafts.hlsl"

Texture2D<float> font : register(t100);

static const float font_scale = 1.0;
static float2 cur_pos;
static float4 resolution;
static float2 char_size;
static int2 meta_pos_start;

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
	uint output_char3 = ' ';
	float4 output_float = 0;

	stereoise_light_shaft_parameters();

	// Reducing complexity that depends on flow control - not because I
	// care about performance on the GPU, but because the compiler takes
	// exponentially longer the more flow control is used.
	uint n = 15;
	if (idx <= 3) {
		// Vector2(0, 0), new Vector2(1, 0), new Vector2(1, 1), new Vector2(0, 1)};
		output_char1 = 'L';
		output_char2 = (idx % 4) == 1 || (idx % 4) == 2 ? '1' : '0';
		output_char3 = (idx % 4) >= 2 ? '1' : '0';
		output_float = _FrustumRays[(idx % 4)];
	} else if (idx <= 7) {
		output_char1 = '+';
		output_char2 = (idx % 4) == 1 || (idx % 4) == 2 ? '1' : '0';
		output_char3 = (idx % 4) >= 2 ? '1' : '0';
		output_float = stereo_FrustumRays[idx % 4];
	} else if (idx <= 11) {
		output_char1 = 'W';
		output_char2 = (idx % 4) == 1 || (idx % 4) == 2 ? '1' : '0';
		output_char3 = (idx % 4) >= 2 ? '1' : '0';
		output_float = world_FrustumRays[idx % 4];
	} else if (idx <= n++) {
		output_char1 = 'I'; output_char2 = 'V'; output_char3 = 'P';
		output_float = I_VP[idx % 4];
	} else if (idx == n++) {
		output_char1 = 'F'; output_char2 = 'X';
		float local = distance(_FrustumRays[0].xyz, _FrustumRays[1].xyz);
		float world = distance(world_FrustumRays[0].xyz, world_FrustumRays[1].xyz);
		output_float = float4(local, world, local_to_world_scale.x, local / world);
	} else if (idx == n++) {
		output_char1 = 'F'; output_char2 = 'Y';
		float local = distance(_FrustumRays[1].xyz, _FrustumRays[2].xyz);
		float world = distance(world_FrustumRays[1].xyz, world_FrustumRays[2].xyz);
		output_float = float4(local, world, local_to_world_scale.y, local / world);
	} else if (idx == n++) {
		output_char1 = 'F'; output_char2 = 'D';
		float local = distance(_FrustumRays[0].xyz, _FrustumRays[2].xyz);
		float world = distance(world_FrustumRays[0].xyz, world_FrustumRays[2].xyz);
		output_float = float4(local, world, world / local, local / world);
	} else if (idx == n++) {
		output_char1 = 'F'; output_char2 = 'Z';
		output_float = float4(local_far, _ProjectionParams.z, local_to_world_scale.z, world_far);
	} else if (idx == n++) {
		output_char1 = 'C'; output_char2 = 'X';
		output_float = local_cam_axis[0];
	} else if (idx == n++) {
		output_char1 = 'C'; output_char2 = 'Y';
		output_float = local_cam_axis[1];
	} else if (idx == n++) {
		output_char1 = 'C'; output_char2 = 'Z';
		output_float = local_cam_axis[2];
	} else if (idx == n++) {
		output_char1 = 'A'; output_char2 = 'P';
		output_float = float4(_FrustumApex, 0, 0, 0);
	} else if (idx == n++) {
		output_char1 = 'L'; output_char2 = 'L';
		output_float = float4(local_light_pos, 0);
	} else if (idx == n++) {
		output_char1 = 'L'; output_char2 = 'S';
		output_float = _LightPos;
	} else if (idx == n++) {
		output_char1 = 'L'; output_char2 = 'S'; output_char3 = '+';
		output_float = stereo_LightPos;
	} else if (idx == n++) {
		output_char1 = 'C'; output_char2 = 'L';
		output_float = _CameraPosLocal;
	} else if (idx == n++) {
		output_char1 = 'C'; output_char2 = 'L'; output_char3 = '+';
		output_float = stereo_CameraPosLocal;
	} else if (idx == n++) {
		output_char1 = 'C'; output_char2 = 'W';
		output_float = float4(_WorldSpaceCameraPos, 0);
	} else if (idx == n++) {
		output_char1 = 'C'; output_char2 = 'S';
		output_float = _CameraPosLocal * (_ProjectionParams.z / local_far);
	}

	emit_char(output_char1, ostream);
	emit_char(output_char2, ostream);
	emit_char(output_char3, ostream);
	emit_char(' ', ostream);
	emit_float(output_float.x, ostream);
	emit_char(' ', ostream);
	emit_float(output_float.y, ostream);
	emit_char(' ', ostream);
	emit_float(output_float.z, ostream);
	emit_char(' ', ostream);
	emit_float(output_float.w, ostream);
}
