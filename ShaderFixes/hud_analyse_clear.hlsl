Texture2D<float4> StereoParams : register(t125);
Texture1D<float4> IniParams : register(t120);

#include "hud.hlsl"

RWStructuredBuffer<struct hud_info> HUD_Depth_UAV : register(u0);

[numthreads(1, 1, 1)]
void main()
{
	HUD_Depth_UAV[0].pos = cursor_pos * 2 - 1;
	HUD_Depth_UAV[0].selection_circle_seen = false;
	HUD_Depth_UAV[0].action_icon_seen = false;
	HUD_Depth_UAV[0].loading_seen = false;
}
