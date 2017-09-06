Texture2D<float4> StereoParams : register(t125);
Texture1D<float4> IniParams : register(t120);

#include "hud.hlsl"

void main(float4 pos : SV_Position0, out float result : SV_Target0)
{
	uint width, height;

	hud_depth.GetDimensions(width, height);

	// Nearly equivalent to using adjust_from_stereo2mono_depth_buffer
	// favouring the cursor dropping to the background where there is
	// something obscuring the view in one eye, but uses separate depth
	// tests performed on each eye that were merged together into a
	// stereo2mono resource, which gives significantly better performance
	// in SLI* since only one pixel needs to be sent between GPUs instead
	// of the entire depth buffer (which was a problem above 1080p).
	if (stereo_eye == 1)
		result = min(-hud_depth.Load(int3(pos.x, pos.y, 0)), hud_depth.Load(int3(pos.x + width / 2, pos.y, 0)));
	else
		result = max(hud_depth.Load(int3(pos.x, pos.y, 0)), -hud_depth.Load(int3(pos.x + width / 2, pos.y, 0)));
}
