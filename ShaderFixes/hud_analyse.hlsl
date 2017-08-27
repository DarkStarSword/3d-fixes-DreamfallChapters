Texture2D<float4> StereoParams : register(t125);
Texture1D<float4> IniParams : register(t120);

#include "hud.hlsl"

RWStructuredBuffer<struct hud_info> HUD_Depth_UAV : register(u0);

cbuffer cb0 : register(b13)
{
  float4 cb0[4];
}

// This matches the vertex buffer structure of the shader we get it from. Note
// that the structure here is similar, but not identical to the input signature
// of that shader - in particular, the color input is completely missing. For
// now the best way to determine this is to dump the vertex buffer (and index
// buffer if applicable) with frame analysis and study it.
struct vb_0bd32bb622c2d611_entry
{
	float4 vb_position;
	float2 vb_texcoord;
};

StructuredBuffer<struct vb_0bd32bb622c2d611_entry> vb_0bd32bb622c2d611_struct : register(t100);

// This comes from the mentioned shader to calculate o0
float2 calc_0bd32bb622c2d611_pos(float4 pos)
{
	float4 r0, o0;

	r0 = cb0[1].xyzw * pos.yyyy;
	r0 = cb0[0].xyzw * pos.xxxx + r0.xyzw;
	r0 = cb0[2].xyzw * pos.zzzz + r0.xyzw;
	o0 = cb0[3].xyzw * pos.wwww + r0.xyzw;

	return o0.xy * float2(1, -1);
}

// Average the position of all vertices in this quad to find the center
//
// Worth noting that this shader does use an index buffer, but it is
// just a trivial 0, 1, 2, 2, 3, 0 quad so we ignore it here
float4 find_quad_center()
{
	float4 pos = 0;

	pos += vb_0bd32bb622c2d611_struct[0].vb_position;
	pos += vb_0bd32bb622c2d611_struct[1].vb_position;
	pos += vb_0bd32bb622c2d611_struct[2].vb_position;
	pos += vb_0bd32bb622c2d611_struct[3].vb_position;

	// Returning W=1 is important here, though the symptoms are weird -
	// before the first F10 reload W goes to 0 and messes up the position
	// calculation, however after an F10 reload W still goes to 0, but does
	// not mess up the position calculation. NFI why this would be, but
	// returning W=1 avoids the issue.
	return float4(pos.xy / 4, 0, 1);
}

[numthreads(1, 1, 1)]
void main()
{
	if (HUD_Depth_UAV[0].selection_circle_seen)
		return;

	HUD_Depth_UAV[0].pos = calc_0bd32bb622c2d611_pos(find_quad_center());

	if (texture_filter == selection_circle)
		HUD_Depth_UAV[0].selection_circle_seen = true;
}
