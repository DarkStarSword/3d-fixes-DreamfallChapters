#include "light_shafts.hlsl"

void main(
		out float4 pos : SV_Position0,
		uint vertex : SV_VertexID)
{
	stereoise_light_shaft_parameters();

	pos.xy = _LightPos.xy;
	if (IniParams[7].y)
		pos.xy = stereo_LightPos.xy;
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

	if (stereo_LightPos.w  <= 0)
		pos = 0;
}
