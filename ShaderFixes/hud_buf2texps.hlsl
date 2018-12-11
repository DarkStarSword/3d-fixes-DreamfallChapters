Texture2D<float4> StereoParams : register(t125);
Texture1D<float4> IniParams : register(t120);

#include "hud.hlsl"

void main(float4 pos : SV_Position0, out float result : SV_Target0)
{
	float2 text_pos;
	int2 pixel = floor(pos.xy);

	// This shader is used to record the depths at various points from this
	// eye. The reverse stereo blit will be used to then gain access to the
	// depths of these points from both eyes before a decision is made as
	// which to use.

	if (pixel.x == 0) {
		result = adjust_from_depth_buffer(hud_srv[0].pos.x, hud_srv[0].pos.y);
	} else if (pixel.x - 1 < hud_srv[0].text_counter) {
		text_pos = hud_srv[0].text_pos[pixel.x - 1];
		result = adjust_from_depth_buffer(text_pos.x, text_pos.y);
	} else {
		discard;
		result = 0;
	}
}
