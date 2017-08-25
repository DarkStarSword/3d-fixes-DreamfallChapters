Texture2D<float4> StereoParams : register(t125);
Texture1D<float4> IniParams : register(t120);

#include "hud.hlsl"

void main(float4 pos : SV_Position0, out float result : SV_Target0)
{
	result = adjust_from_depth_buffer(hud_srv[0].pos.x, hud_srv[0].pos.y);
}
