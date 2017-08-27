Texture2D<float4> StereoParams : register(t125);
Texture1D<float4> IniParams : register(t120);

#include "hud.hlsl"

void main(
		out float4 pos : SV_Position0,
		uint vertex : SV_VertexID)
{
	pos.xy = hud_srv[0].pos;
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

	if (IniParams[7].y)
		to_hud_depth(pos);
}
