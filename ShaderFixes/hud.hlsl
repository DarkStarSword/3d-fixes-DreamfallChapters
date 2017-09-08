#include "crosshair.hlsl"

#define separation StereoParams.Load(0).x
#define convergence StereoParams.Load(0).y
#define stereo_eye StereoParams.Load(0).z

#define min_subtitle_depth IniParams[0].x
#define cursor_pos         IniParams[1].xy
#define texture_filter     IniParams[1].z
#define hud_shader         IniParams[1].w
#define rt_size            IniParams[4].xy
#define res_size           IniParams[4].zw

#define hud_shader_floating_icons 1
#define hud_shader_inventory_examine_icons 2
#define hud_shader_text 3

#define inventory_depth IniParams[2].x
#define inventory_depth_examine IniParams[2].x

#define selection_circle 2
// #define subtitle_text 3 // Hash proved unreliable - if we need this, try enabling hash tracking
#define loading_screen_graphic 4
#define action_icon 5
#define inventory_circle 6
#define inventory_examine_circles 7

#ifndef IS_FULLSCREEN
#define IS_FULLSCREEN false
#endif

struct hud_info {
	/*  0:8  */ float2 pos;
	/*  8:12 */ bool selection_circle_seen;
	/* 12:16 */ bool action_icon_seen;
	/* 16:20 */ bool icon_seen;
	/* 20:24 */ bool loading_seen;
	/* 24:28 */ int inventory_seen;
	/* 28:32 */ int text_counter;
	/* 32:96 */ float2 text_pos[8];
};

StructuredBuffer<struct hud_info> hud_srv : register(t105);
Texture2D<float> hud_depth : register(t106);

void to_hud_depth(inout float4 pos)
{
	// Disable HUD adjustment entirely whenever loading graphic is on screen:
	if (hud_srv[0].loading_seen)
		return;

	// Do not adjust full screen backgrounds:
	if (IS_FULLSCREEN)
		return;

	if (hud_srv[0].inventory_seen == 2) {
		// Inventory is being examined, adjust all HUD icons to same
		// depth, removing any adjustment they may already have:
		if (pos.w != 1)
			pos.x -= separation * (pos.w - convergence);
		pos.x += separation * (inventory_depth_examine - convergence) / inventory_depth_examine * pos.w;
		return;
	}

	// Inventory HUD is drawn with W != 0. Leave it alone for now. Maybe
	// later we can detect it and line the cursor up with it, or move it to
	// a more appropriate depth.
	if (pos.w != 1)
		return;

	if (hud_srv[0].inventory_seen == 1) {
		// Inventory is active but not examining, adjust so that the cursor lines up
		pos.x += separation * (inventory_depth - convergence) / inventory_depth;
		return;
	}

	if (!hud_srv[0].icon_seen == 1 && hud_srv[0].text_counter > 0) {
		float min_adj = 1.#INF;
		uint i;

		// No icons were drawn/captured, but non-subtitle text was. Use
		// the depth of the closest text to makes conversation choice
		// text comfortable.
		for (i = 0; i < hud_srv[0].text_counter; i++)
			min_adj = min(min_adj, -stereo_eye * hud_depth.Load(int3(1 + i, 0, 0)));

		pos.x += -stereo_eye * min_adj;
		return;
	}

	pos.x += hud_depth.Load(int3(0, 0, 0));
}

bool is_subtitle(float4 cb0_3)
{
	return all(cb0_3.xzw == float3(0, 0.5, 1)) && (
		cb0_3.y == -0.8 || /* Regular subtitles */
		cb0_3.y < -0.6); /* Two subtitles rendered simultaneously */
}

void handle_subtitle(inout float4 pos)
{
	// For now probe several spots on the depth buffer and use the smallest
	float depth = 1.#INF;
	float x, y;

	for (x = -0.8, y = 0.8; x <= 0.8; x += 0.02) {
		depth = min(depth, world_z_from_depth_buffer(x, y));
	}

	pos.x += separation * max((depth - convergence) / depth, min_subtitle_depth);
}

void handle_text(inout float4 pos, float4 cb0_3)
{
	if (is_subtitle(cb0_3))
		handle_subtitle(pos);
	else
		to_hud_depth(pos);
}
