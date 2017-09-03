Texture2D<float4> StereoParams : register(t125);
Texture1D<float4> IniParams : register(t120);

void main(out float4 result : SV_Target0)
{
	result = float4(0, 0, 0, 1);
}
