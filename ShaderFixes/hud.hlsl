#include "crosshair.hlsl"

#define separation StereoParams.Load(0).x
#define convergence StereoParams.Load(0).y

#define subtitle_depth IniParams[0].x
#define cursor_pos     IniParams[1].xy
#define texture_filter IniParams[1].z

#define selection_circle 2
#define subtitle_text 3

struct hud_info {
	float2 pos;
	bool selection_circle_seen;
};

StructuredBuffer<struct hud_info> hud_srv : register(t105);
Texture2D<float> hud_depth : register(t106);

void to_hud_depth(inout float4 pos)
{
	// Nearly equivelent to using adjust_from_stereo2mono_depth_buffer
	// favouring the cursor dropping to the background where there is
	// something obscuring the view in one eye, but uses separate depth
	// tests performed on each eye that were merged together into a
	// stereo2mono resource, which gives significantly better performance
	// in SLI* since only one pixel needs to be sent between GPUs instead
	// of the entire depth buffer (which was a problem above 1080p).
	float eye = StereoParams.Load(0).z;
	if (eye == 1)
		pos.x += min(-hud_depth.Load(int3(0, 0, 0)), hud_depth.Load(int3(1, 0, 0)));
	else
		pos.x += max(hud_depth.Load(int3(0, 0, 0)), -hud_depth.Load(int3(1, 0, 0)));
}

void handle_subtitle(inout float4 pos)
{
	// For now probe several spots on the depth buffer and use the smallest
	float depth = 1.#INF;
	float x, y;

	for (x = -0.8, y = 0.8; x <= 0.8; x += 0.1) {
		depth = min(depth, world_z_from_depth_buffer(x, y));
	}

	pos.x += separation * (depth - convergence) / depth;
}

void handle_text(inout float4 pos)
{
	if (pos.y < -0.75 && texture_filter == subtitle_text) {
		handle_subtitle(pos);
		return;
	}

	to_hud_depth(pos);
}
