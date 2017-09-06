Texture2D<float4> StereoParams : register(t125);
Texture1D<float4> IniParams : register(t120);

#include "hud.hlsl"

RWStructuredBuffer<struct hud_info> HUD_Depth_UAV : register(u0);

// Copied from 0bd32bb622c2d611, in register b13 but still called cb0 so that
// the vb include doesn't have to distinguish between the original and this one:
cbuffer cb0 : register(b13)
{
  float4 cb0[4];
}

#include "hud_vb_0bd32bb622c2d611.hlsl"

void analyse_floating_icons_shader()
{
	float2 pos;

	// Disable HUD adjustment entirely whenever loading graphic is on screen:
	if (texture_filter == loading_screen_graphic) {
		HUD_Depth_UAV[0].loading_seen = true;
		return;
	}

	// Set fixed depth whenever inventory circle is on screen:
	if (HUD_Depth_UAV[0].inventory_seen)
		return;
	if (texture_filter == inventory_circle) {
		HUD_Depth_UAV[0].inventory_seen = 1;
		return;
	}

	pos = calc_0bd32bb622c2d611_pos(find_quad_center()) * float2(1, -1);

	// Selection circle has priority over everything else:
	if (HUD_Depth_UAV[0].selection_circle_seen)
		return;
	if (texture_filter == selection_circle) {
		HUD_Depth_UAV[0].selection_circle_seen = true;
		HUD_Depth_UAV[0].icon_seen = true;
		HUD_Depth_UAV[0].pos = pos;
		return;
	}

	// Don't adjust HUD based on icons at edge of screen (off-screen dialog
	// marker vs whatever you are looking at)
	if (any(pos.xy < -0.8) || any(pos.xy > 0.8))
		return;

	// Action icons have priority over random other graphics (important so
	// that the location text doesn't steal the HUD depth):
	if (HUD_Depth_UAV[0].action_icon_seen)
		return;
	if (texture_filter == action_icon) {
		HUD_Depth_UAV[0].pos = pos;
		HUD_Depth_UAV[0].icon_seen = true;
		HUD_Depth_UAV[0].action_icon_seen = true;
		return;
	}

	// Whatever other graphics are drawn with this shader will get the HUD
	// depth if no higher priority HUD elements are also present:
	HUD_Depth_UAV[0].pos = pos;
	HUD_Depth_UAV[0].icon_seen = true;
}

void analyse_inventory_shader()
{
	// Set fixed depth whenever inventory is being examined:
	if (texture_filter == inventory_examine_circles)
		HUD_Depth_UAV[0].inventory_seen = 2;
}

void analyse_text_shader()
{
	// Subtitles use a simple adjustment in the hud shader, not here:
	if (is_subtitle(cb0[3]))
		return;

	// Floating text next to icons does not use the MVP for position,
	// disregard it:
	if (all(cb0[3].xy == 0))
		return;

	// Record the positions of any remaining text being drawn - this will
	// capture the dialog choices text:
	int idx = HUD_Depth_UAV[0].text_counter;
	if (idx < 8) {
		HUD_Depth_UAV[0].text_pos[idx] = cb0[3].xy * float2(1, -1);
		HUD_Depth_UAV[0].text_counter = idx + 1;
	}
}


[numthreads(1, 1, 1)]
void main()
{
	switch (hud_shader) {
		case hud_shader_floating_icons:
			analyse_floating_icons_shader();
			return;
		case hud_shader_inventory_examine_icons:
			analyse_inventory_shader();
			return;
		case hud_shader_text:
			analyse_text_shader();
			return;
	}
}
