#include "light_shafts.hlsl"

RWStructuredBuffer<Globals> Output : register(u0);

[numthreads(1, 1, 1)]
void main()
{
	stereoise_light_shaft_parameters();

	Output[0]._LightPos = stereo_LightPos;
	Output[0]._FrustumRays = stereo_FrustumRays;
	Output[0]._CameraPosLocal = stereo_CameraPosLocal;

	Output[0]._FrustumApex = _FrustumApex;
	Output[0]._CoordTexDim = _CoordTexDim;
	Output[0]._ScreenTexDim = _ScreenTexDim;
	Output[0]._LightColor = _LightColor;
	Output[0]._Extinction = _Extinction;
	Output[0]._Brightness = _Brightness;
	Output[0]._MinDistFromCamera = _MinDistFromCamera;
}
