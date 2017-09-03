Texture1D<float4> IniParams : register(t120);

void main(
		out float4 pos : SV_Position0,
		out float4 spos : TEXCOORD0,
		out float2 tpos : TEXCOORD1,
		uint vertex : SV_VertexID)
{
	if (!IniParams[5].x) {
		pos = 0;
		return;
	}

	// Not using vertex buffers so manufacture our own coordinates.
	switch(vertex) {
		case 0:
			pos.xy = float2(-1, -1);
			break;
		case 1:
			pos.xy = float2(-1, 1);
			break;
		case 2:
			pos.xy = float2(1, -1);
			break;
		case 3:
			pos.xy = float2(1, 1);
			break;
		default:
			pos.xy = 0;
			break;
	};
	pos.zw = float2(0, 1);
	spos = pos;
	tpos = pos.xy * float2(0.5,-0.5) + 0.5;
}
