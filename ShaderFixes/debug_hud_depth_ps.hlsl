Texture2D<float4> StereoParams : register(t125);
Texture1D<float4> IniParams : register(t120);

#include "hud.hlsl"

void main(float4 pos : SV_Position0, out float4 result : SV_Target0)
{
	result = float4(0, 0, 1, 1);
	if (IniParams[7].y == 1)
		result = float4(1, 0, 0, 1);
	else if (IniParams[7].y == 2)
		result = float4(0, 1, 0, 1);
}
