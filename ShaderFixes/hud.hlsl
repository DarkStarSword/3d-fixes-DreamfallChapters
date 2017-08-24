#define cursor_pos IniParams[1].xy

#include "crosshair.hlsl"

struct hud_info {
	float2 pos;
};

StructuredBuffer<struct hud_info> hud_srv : register(t105);

void to_hud_depth(inout float4 pos)
{
	pos.x += adjust_from_depth_buffer(hud_srv[0].pos.x, hud_srv[0].pos.y);
}
