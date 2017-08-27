Texture2D<float4> StereoParams : register(t125);
Texture1D<float4> IniParams : register(t120);

#include "hud.hlsl"

RWStructuredBuffer<struct hud_info> HUD_Depth_UAV : register(u0);

// Copied from 0bd32bb622c2d611, in register b13 but still called cb0 so that
// the vb include doesn't have to distinguish between the original and this one:
cbuffer cb0 : register(b13)
{
  float4 cb0[4];
}

#include "hud_vb_0bd32bb622c2d611.hlsl"

[numthreads(1, 1, 1)]
void main()
{
	if (texture_filter == loading_screen_graphic) {
		HUD_Depth_UAV[0].loading_seen = true;
		return;
	}

	if (HUD_Depth_UAV[0].selection_circle_seen)
		return;

	HUD_Depth_UAV[0].pos = calc_0bd32bb622c2d611_pos(find_quad_center()) * float2(1, -1);

	if (texture_filter == selection_circle)
		HUD_Depth_UAV[0].selection_circle_seen = true;
}
