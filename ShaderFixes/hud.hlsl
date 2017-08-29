#include "crosshair.hlsl"

#define separation StereoParams.Load(0).x
#define convergence StereoParams.Load(0).y

#define subtitle_depth IniParams[0].x
#define cursor_pos     IniParams[1].xy
#define texture_filter IniParams[1].z
#define hud_shader     IniParams[1].w

#define hud_shader_floating_icons 1
#define hud_shader_inventory_examine_icons 2

#define inventory_depth IniParams[2].x // FIXME: Preset release seems buggy and is not restoring the right value
#define inventory_depth_examine IniParams[2].x

#define selection_circle 2
#define subtitle_text 3
#define loading_screen_graphic 4
#define action_icon 5
#define inventory_circle 6
#define inventory_examine_circles 7

#ifndef IS_FULLSCREEN
#define IS_FULLSCREEN false
#endif

struct hud_info {
	float2 pos;
	bool selection_circle_seen;
	bool action_icon_seen;
	bool loading_seen;
	int inventory_seen;
};

StructuredBuffer<struct hud_info> hud_srv : register(t105);
Texture2D<float> hud_depth : register(t106);

void to_hud_depth(inout float4 pos)
{
	if (hud_srv[0].loading_seen)
		return;

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

	// Nearly equivelent to using adjust_from_stereo2mono_depth_buffer
	// favouring the cursor dropping to the background where there is
	// something obscuring the view in one eye, but uses separate depth
	// tests performed on each eye that were merged together into a
	// stereo2mono resource, which gives significantly better performance
	// in SLI* since only one pixel needs to be sent between GPUs instead
	// of the entire depth buffer (which was a problem above 1080p).
	float eye = StereoParams.Load(0).z;
	if (eye == 1)
		pos.x += min(-hud_depth.Load(int3(0, 0, 0)), hud_depth.Load(int3(1, 0, 0)));
	else
		pos.x += max(hud_depth.Load(int3(0, 0, 0)), -hud_depth.Load(int3(1, 0, 0)));
}

void handle_subtitle(inout float4 pos)
{
	// For now probe several spots on the depth buffer and use the smallest
	float depth = 1.#INF;
	float x, y;

	for (x = -0.8, y = 0.8; x <= 0.8; x += 0.1) {
		depth = min(depth, world_z_from_depth_buffer(x, y));
	}

	pos.x += separation * (depth - convergence) / depth;
}

void handle_text(inout float4 pos)
{
	if (pos.y < -0.7 && texture_filter == subtitle_text) {
		handle_subtitle(pos);
		return;
	}

	to_hud_depth(pos);
}
