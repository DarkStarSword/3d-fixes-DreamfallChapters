Texture2D<float4> StereoParams : register(t125);
Texture1D<float4> IniParams : register(t120);

#include "hud.hlsl"

void main(
		out float4 pos : SV_Position0,
		uint vertex : SV_VertexID)
{
	uint depth_idx = vertex / 6;

	if (depth_idx == 0) {
		pos.xy = hud_srv[0].pos;
	} else {
		int text_idx = depth_idx - 1;
		if (text_idx >= hud_srv[0].text_counter) {
			pos = 0;
			return;
		}
		pos.xy = hud_srv[0].text_pos[text_idx];
	}
	if (IniParams[7].y == 2)
		pos.xy = cursor_pos * 2 - 1;
	pos.y *= -1;

	// Not using vertex buffers so manufacture our own coordinates.
	switch(vertex % 6) {
		case 0:
			pos.xy += float2(-0.005, -0.005);
			break;
		case 1:
		case 4:
			pos.xy += float2(-0.005, 0.005);
			break;
		case 2:
		case 3:
			pos.xy += float2(0.005, -0.005);
			break;
		case 5:
			pos.xy += float2(0.005, 0.005);
			break;
		default:
			pos.xy = 0;
			break;
	};
	pos.zw = float2(0, 1);

	if (IniParams[7].y == 1) {
		if (depth_idx == 0)
			to_hud_depth(pos);
		else
			pos.x += hud_depth.Load(int3(depth_idx, 0, 0));
	} else if (IniParams[7].y == 2) {
		pos.x += adjust_from_depth_buffer(cursor_pos.x * 2 - 1, cursor_pos.y * 2 - 1);
	}
}
