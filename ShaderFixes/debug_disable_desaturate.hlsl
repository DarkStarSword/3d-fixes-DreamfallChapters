// 3DMigoto: 5ce2a8d8509f86d8 |    Unity headers extracted from DesaturateEffect.shader
//    Shader "Hidden/Desaturate Effect" {
//      Properties {
//       _MainTex ("Base (RGB)", 2D) = "white" { }
//       _RampTex ("Base (RGB)", 2D) = "grayscaleRamp" { }
//       _Desat ("Desaturate", Float) = 0.500000
//      }
//      Fallback Off
//      SubShader 1/1 {
//        Pass 1/1 {
//          ZTest Always
//          ZWrite Off
//          Cull Off
//          GpuProgramID 23698
//          Program "fp" {
//            SubProgram "d3d11 " {
//              GpuProgramIndex 4
//            }
//          }
//        }
//      }
//    }
//
// Unity 5.3 headers extracted from DesaturateEffect.shader.decompressed:
//   API d3d11
//   Shader model ps_4_0
//   undeciphered1: 201510240 11 2 0
//   undeciphered2: 1 2 1 2 0 0
//   undeciphered3: 0 0
//   ConstBuffer "$Globals" 128
//   Vector 48 [unity_ColorSpaceLuminance]
//   Vector 96 [_RampOffset]
//   Float 112 [_Desat]
//   SetTexture 0 [_MainTex] 2D 0
//   SetTexture 1 [_RampTex] 2D 1
//   BindCB "$Globals" 0
//
// Headers extracted with DarkStarSword's extract_unity53_shaders.py
// https://github.com/DarkStarSword/3d-fixes

// ---- Created with 3Dmigoto v1.2.61 on Thu Aug 17 01:18:09 2017
Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);


// Unity constant buffers reconstructed with DarkStarSword's hlsltool.py:
// hlsltool.py --reconstruct-unity-cbuffers -I ../.. --fxc /home/dss/fxc.exe 5ce2a8d8509f86d8-ps_replace.txt

cbuffer Globals : register(b0) {
  float4 unity_ColorSpaceLuminance : packoffset(c3);
  float4 _RampOffset : packoffset(c6);
  float _Desat : packoffset(c7);
}




// 3Dmigoto declarations
#define cmp -
Texture1D<float4> IniParams : register(t120);
Texture2D<float4> StereoParams : register(t125);


void main( 
  float4 v0 : SV_POSITION0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t0.Sample(s0_s, v1.xy).xyzw;

o0 = r0;
return;

  r1.xyz = unity_ColorSpaceLuminance.xyz * r0.xyz;
  r1.xz = r1.xx + r1.yz;
  r1.y = r1.y * r1.z;
  r1.x = r0.z * unity_ColorSpaceLuminance.z + r1.x;
  r1.y = sqrt(r1.y);
  r1.y = dot(unity_ColorSpaceLuminance.ww, r1.yy);
  r1.x = r1.x + r1.y;
  r1.y = 0.5;
  r1.xyzw = t1.Sample(s1_s, r1.xy).xyzw;
  r1.xyz = _Desat * r1.xyz;
  r1.w = 1 + -_Desat;
  r0.xyz = r0.xyz * r1.www + r1.xyz;
  o0.w = r0.w;
  o0.xyz = _RampOffset.xyz + r0.xyz;
  return;
}
