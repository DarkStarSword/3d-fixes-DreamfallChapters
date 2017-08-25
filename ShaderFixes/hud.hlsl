#define cursor_pos IniParams[1].xy

#include "crosshair.hlsl"

struct hud_info {
	float2 pos;
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
