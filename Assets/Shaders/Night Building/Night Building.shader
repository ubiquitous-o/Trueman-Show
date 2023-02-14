
// Copyright (c) 2020 @yossy222_VRC
// Released under the MIT license
// https://opensource.org/licenses/mit-license.php

// Original Code by
// <Booth>
// Star Nest Shader HLSL by @Feyris77
// https://voxelgummi.booth.pm/items/1121090
// <Shadertoy>
// "Auroras" by nimitz | Shadertoy
// https://www.shadertoy.com/view/XtGGRt
// "Happy 2020!" by piyushslayer | Shadertoy
// https://www.shadertoy.com/view/tt3GRN
// "MOON" by zxxuan1001 | Shadertoy
// https://www.shadertoy.com/view/tstGWH

Shader "Skybox/Night Building"
{
Properties {
	[Header(Position Setting)]
	_Position   ("Position (X.Y.Z) [全体位置]", Vector) = (1., .5, .5, 0)
	_Speed      ("Speed (X.Y.Z) [スクロール速度]", Vector) = (1., .5, .5, 0)
	[Header(Loop Setting)]
	[IntRange]_Volsteps   ("Vol Steps  (int) [全体ループ数]", Range(1, 32)) = 20
	[IntRange]_Iterations ("Iterations (int) [サブループ数]", Range(1, 32)) = 17
	[Header(Visual Setting)]
	[HDR]_Color ("Color (HDR)", Color) = (1,1,1,1)
	_Formuparam ("Formuparam", Range(0, 1)) = .53
	_Stepsize   ("Step Size [ステップサイズ]", Range(0, 2)) = 0.145
	_Zoom       ("Zoom [拡大率]", Range(0, 3)) =0.8
	_Tile       ("Tile [タイリング数]", Range(0, 1)) =0.85
	_Fade       ("Fade [暗転率]", Range(0, 2)) = .23
	_Brightness ("Brightness [輝度]",Range(0, .1)) = 0.0015
	_Darkmatter ("Darkmatter [ダークマター]",Range(0, 2)) = 0.3
	_Distfading ("Distance Fading [褪色]",Range(0, 2)) = 0.73
	_Saturation ("Saturation [彩度]",Range(0, 2)) = 0.85
	[Header(Option Setting)]
	[Toggle] _Is_Bloom("IsBloom [Blume効果無効]", Float) = 0
	[Header(Toggle Effect)]
	[Toggle(_IS_STAR_ON)] _Star("Star", Float) = 1
	[Toggle(_IS_AURORA_ON)] _Aurora("Aurora", Float) = 1
	[Toggle(_IS_BUILDING_ON)] _Building("Building", Float) = 1
	[Toggle(_IS_MOON_ON)] _Moon("Moon", Float) = 1
	[HideInInspector]_MainTex("MainTex",2D) = "white"{}
}
	SubShader
	{
		Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
		Cull Off ZWrite Off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ _IS_BLOOM_ON
			#pragma shader_feature _IS_STAR_ON
			#pragma shader_feature _IS_AURORA_ON
			#pragma shader_feature _IS_BUILDING_ON
			#pragma shader_feature _IS_MOON_ON

			#include "UnityCG.cginc"

			int _Iterations, _Volsteps;
			float _Formuparam, _Stepsize, _Zoom, _Tile, _Fade;
			float _Brightness,  _Darkmatter, _Distfading, _Saturation;
			float3 _Color, _Position, _Speed;
			sampler2D _MainTex;

			struct appdata_t {
				float4 vertex : POSITION;
				float3 uv:TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float3 uv : TEXCOORD0;
				float3 pos : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.pos = normalize(mul(unity_ObjectToWorld, v.vertex.xyz));
				o.uv = v.uv;
				return o;
			}

			// Aurora start
			float2x2 mm2(in float a) { float c = cos(a), s = sin(a); return float2x2(c, -s, s, c); }
			float2x2 m2 = float2x2(0.95534, -0.29552, 0.29552, 0.95534);
			float tri(in float x) { return clamp(abs(frac(x) - .5), 0.01, 0.49); }
			fixed2 tri2(in fixed2 p) { return fixed2(tri(p.x) + tri(p.y), tri(p.y + tri(p.x))); }
			float triNoise2d(in fixed2 p, float spd)
			{
				float z = 1.8;
				float z2 = 2.5;
				float rz = 0.;
				p = mul(p, mm2(p.x*0.06));
				fixed2 bp = p;
				for (float i = 0.; i<5.; i++)
				{
					fixed2 dg = tri2(bp*1.85)*.75;
					dg = mul(dg, mm2(_Time.y*spd));
					p -= dg / z2;
					bp *= 1.3;
					z2 *= .45;
					z *= .42;
					p *= 1.21 + (rz - 1.0)*.02;
					rz += tri(p.x + tri(p.y))*z;
					p = mul(p, -m2);
				}
				return clamp(1. / pow(rz*29., 1.3), 0., .55);
			}
			float hash21(in fixed2 n) { return frac(sin(dot(n, fixed2(12.9898, 4.1414))) * 43758.5453); }
			fixed4 aurora(fixed3 ro, fixed3 rd, fixed2 pos)
			{
				fixed4 col = fixed4(0, 0, 0, 0);
				fixed4 avgCol = fixed4(0, 0, 0, 0);
				for (float i = 0.; i<50.; i++)
				{
					float of = 0.006 * hash21(pos.xy) * smoothstep(0., 15., i);
					float pt = ((.8 + pow(i, 1.4)*.002) - ro.y) / (rd.y*2. + 0.4);
					pt -= of;
					fixed3 bpos = ro + pt * rd;
					fixed2 p = bpos.zx;
					float rzt = triNoise2d(p, 0.06);
					fixed4 col2 = fixed4(0, 0, 0, rzt);
					col2.rgb = (sin(1. - fixed3(2.15, -.5, 1.2) + i * 0.043) * 0.5 + 0.5) * rzt;
					avgCol = lerp(avgCol, col2, .5);
					col += avgCol*exp2(-i*0.065 - 2.5)*smoothstep(0., 5., i);
				}
				col *= (clamp(rd.y*15. + .4, 0., 1.));
				return col*1.2;
			}
			fixed3 hash33(fixed3 p)
			{
				p = frac(p * fixed3(443.8975, 397.2973, 491.1871));
				p += dot(p.zxy, p.yxz + 19.27);
				return frac(fixed3(p.x * p.y, p.z*p.x, p.y*p.z));
			}
			fixed3 stars(in fixed3 p, fixed2 pos)
			{
				fixed3 c = fixed3(0., 0., 0.);
				float res = pos.x*1.;
				for (float i = 0.; i<4.; i++)
				{
					fixed3 q = frac(p*(.15*res)) - 0.5;
					fixed3 id = floor(p*(.15*res));
					fixed2 rn = hash33(id).xy;
					float c2 = 1. - smoothstep(0., .6, length(q));
					c2 *= step(rn.x, .0005 + i*i*0.001);
					c += c2*(lerp(fixed3(1.0, 0.49, 0.1), fixed3(0.75, 0.9, 1.), rn.y)*0.1 + 0.9);
					p *= 1.3;
				}
				return c*c*.8;
			}
			fixed3 bg(in fixed3 rd)
			{
				float sd = dot(normalize(fixed3(-0.5, -0.6, 0.9)), rd)*0.5 + 0.5;
				sd = pow(sd, 5.);
				fixed3 col = lerp(fixed3(0.05, 0.1, 0.2), fixed3(0.1, 0.05, 0.2), sd);
				return col*.63;
			}
			fixed3 renderaurora(v2f i)
			{
				fixed2 p = i.pos;
				fixed3 ro = fixed3(0, 0, -6.7);
				fixed3 rd = normalize(fixed3(p, 1.3));
				fixed3 col = fixed3(0., 0., 0.);
				fixed3 brd = rd;
				float fade = smoothstep(0., 0.01, abs(brd.y))*0.1 + 0.4;
				col = bg(rd)*fade;
				if (rd.y > 0.) {
					fixed4 aur = smoothstep(0., 1.2, aurora(ro, rd, p))*fade;
					//col += stars(rd, p);
					col = col*(1. - aur.a) + aur.rgb;
				}
				else //Reflections
				{
					rd.y = abs(rd.y);
					col = bg(rd)*fade*0.6;
					fixed4 aur = smoothstep(0.0, 2.5, aurora(ro, rd, p));
					//col += stars(rd, p)*0.1;
					col = col*(1. - aur.a) + aur.rgb;
					fixed3 pos = ro + ((0.5 - ro.y) / rd.y)*rd;
					float nz2 = triNoise2d(pos.xz*fixed2(.5, .7), 0.);
					col += lerp(fixed3(0.2, 0.25, 0.5)*0.08, fixed3(0.3, 0.3, 0.5)*0.7, nz2*0.4);
				}
				return col;
			}
			// Aurora end


			// Building start
			#define PI  3.141592653589793
			#define TAU 6.283185307179586
			// Helper macros
			#define C(x) clamp(x, 0., 1.)
			#define S(a, b, x) smoothstep(a, b, x)
			#define F(x,f) (floor(x * f) / f)
			#define UI0 1597334673
			#define UI1 3812015801
			#define UI2 float2(UI0, UI1)
			#define UI3 float3(UI0, UI1, 2798796415)
			#define UIF (1.0 / float(0xffffffff))
			// Hash functions by Dave_Hoskins
			float3 hash31(float p)
			{
				int3 n = int(int(p)) * UI3;
				n = (n.x ^ n.y ^ n.z) * UI3;
				return float3(n) * UIF;
			}
			float hash11(float p)
			{
				int2 n = int(int(p)) * UI2;
				uint q = (n.x ^ n.y) * UI0;
				return float(q) * UIF;
			}
			// Function to remap a value from [a, b] to [c, d]
			float remap(float x, float a, float b, float c, float d)
			{
			    return (((x - a) / (b - a)) * (d - c)) + c;
			}
			// Noise (from iq)
			float noise (in float3 p) {
				float3 f = frac (p);
				p = floor (p);
				f = f * f * (3. - 2. * f);
				f.xy += p.xy + p.z * float2 (37., 17.);
				f.xy = tex2D (_MainTex, (f.xy + .5) / 512.).yx;
				return lerp (f.x, f.y, f.z);
			}
			// Tiny fbm
			float fbm (in float3 p) {
				return noise (p) + noise (p * 2.) / 2. + noise (p * 4.) / 4.;
			}
			// Building window lights from www.shadertoy.com/view/wtt3WB
			float windows (float2 uv, float offset)
			{
			    float2 grid = float2(20., 1.);
			    uv.x += offset;
			    float n1 = fbm((float2(float2(uv * grid)) + .5).xxx);
			    uv.x *= n1 * 6.;
			    float2 id = float2(float2(uv * grid)) + .5;
			    float n = fbm(id.xxx);
			    float2 lightGrid = float2(49. * (n + .2), 250. * n);
			    float n2 = fbm((float2(float2(uv * lightGrid + floor(_Time.y * .4) * .2)) + .5).xyx);
			    float2 lPos = frac(uv * lightGrid);
			    n2 = (lPos.y < .3 || lPos.y > .5) ? 0. : n2;
			    n2 = (lPos.x < .6 || lPos.y > .7) ? 0. : n2;
			    n2 = smoothstep(.225, .5, n2);
				return (uv.y < n - 0.01) ? n2 : 0.;
			}
			// Building skyline
			float buildings(float2 st)
			{
			    // An fbm style amalgamation of various cos functions
			    float b = .1 * F(cos(st.x*4.0 + 1.7), 1.0);
			    b += (b + .3) * 0.3 * F(cos(st.x*4.-0.1), 2.0);
			    b += (b-.01) * 0.1 * F(cos(st.x*12.0), 4.);
			    b += (b-.05) * 0.3 * F(cos(st.x*24.0), 1.0);
			    return C((st.y + b - .1) * 100.);
			}
			fixed4 renderbuildings(v2f i)
			{
					float3 pos = i.uv;
					// tanslate uv coordinate to spherical coordinate
					float3 rot = float3(atan2(pos.x, pos.z), atan2(pos.y, length(pos.xz)), length(pos));

			    float2 uv = (3. * rot.xy - 1) / min(1, 1);
			    uv.y += 1; // shift the horizon a bit lower
			    float reflection = 0.;
			    if (uv.y < 0.)
			    {
			        reflection = 1.;
			        // watery distortion in the lake (improved)
			        uv.x += sin((uv.y * 64. + sin(_Time.y) * .2)
						* cos(uv.y * 128. - cos(_Time.y) * .1)) * .15;
			    }
			    // Our special uv coord that gives us reflection effect for pratically free

					uv.x -= _Time.x * 0.5;

			    float2 st = float2(uv.x, abs(uv.y)*2);
			    float3 col = float(0.);
			    // Background mountain
			    float mountain = sin(0.09 * st.x * 1.17 * cos(0.81 * st.x) + 4.87
					* sin(1.17 * st.x)) * .1 - .18 + st.y;
			    mountain = C(S(-.005, .005, mountain));
			    float building = buildings(st);
			    // Finally blend everything together
			    // Sky color
			    col += float3(.18 - st.y * .1, .18 - st.y * .1, .1 + st.y * .03)*0.1;
			    // Blend the mountain and the sky
			    col = col * mountain + float3(.1 - st.y * .1, .1 - st.y * .1, .08) * (1. - mountain);
			    // Occlude the mountain with the building skyline
			    col *= building;
			    // Yellow-ish window color tint
			    col += windows(st * .1, 2.) * (1.-building) * float3(1.2, 1., .8);
			    // Slightly change of the reflections to watery blueish-green
			    col.r -= reflection * .05;
			    col.gb += reflection * .03;
			    return float4(col, 1.0);
			}
			// Building end


			// Moon start
			#define MOON_COLOR float3(0.6,0.9,0.65)
			#define MOON_GLOW float3(0.75,0.5,0.3)
			float moonhash1(in float2 uv) {
			    return frac(sin(uv.x*100.0 + uv.y*6574.0)*5647.0);
			}
			float moonSmoothNoise(in float2 uv) {
			    float2 luv = frac(uv); //range from 0.0 to 1.0
			    float2 id = floor(uv); //the integer part of uv, 0, 1, 2
			    luv = luv*luv*(3.0 - 2.0*luv); //similar to smoothstep
			    //get values from the cordinates of a square
			    float bl = moonhash1(id);
			    float br = moonhash1(id + float2(1.0, 0.0));
			    float tl = moonhash1(id + float2(0.0, 1.0));
			    float tr = moonhash1(id + float2(1.0, 1.0));
			    float b = lerp(bl, br, luv.x); //interpolate between bl and br
			    float t = lerp(tl, tr, luv.x); //interpolate between tl and tr
			    return lerp(b, t, luv.y);
			}
				float moonfbm(in float2 uv) {
			    float amp = 1.0;
			    float f = 2.0;
			    float h = 0.0;
			    float a = 0.0;
			    for (int i = 0; i < 4; i++){
			        h += amp * moonSmoothNoise(uv*f);
			        a += amp;
			        amp *= 0.5;
			        f *= 2.1;
			    }

			    h /= a;
			    return h;
				}
				fixed4 moon(float3 rot)
				{
			    float2 uv = (2.0*rot.xy - 1)/1;
			    float r = .75;
			    float y = 1;

//					uv.x -= (_Time.x * 0.5);

			    float2 p = uv+float2(0, 0.6);
			    float3 col = 0;
//			    col += lerp(float3(0.0, 0.05,0.1), MOON_GLOW*0.2, exp(-5.0*y));
					float circle = length(p)+r;
			    float moon = clamp(pow(1.0/circle,32.0), 0.0, 1.0);
			    float glow = clamp(pow(1.0/circle, 7.0), 0.0, 1.0);

			    float n = clamp(moonfbm(p-float2(0.1,0.0))*moonfbm(p-float2(-0.2,0.2)), 0.0, 1.0);
			    float shadow = moon*n;
			    float3 moonCol = MOON_COLOR*moon*0.8;
			    float3 glowCol = MOON_GLOW*glow*0.5;

			    col += moonCol*0.4;
			    col += glowCol;
			    col += shadow*MOON_COLOR;

			    return float4(col, 1.0);
				}
				fixed4 rendermoon(v2f i)
				{
					float3 pos = i.uv;
					// tanslate uv coordinate to spherical coordinate
					float3 rot = float3(atan2(pos.x, pos.z), atan2(pos.y, length(pos.xz)), length(pos));
					float4 col = moon(rot);
					rot.y = -1.0 * rot.y;
					col += moon(rot);
					return col;

				}
			// Moon end

			fixed4 renderstar(v2f i)
			{
				float3 from = _Position + _Time.x*_Speed;
				float s = .1, fade = _Fade;
				float3 col;

				[loop]
				for(int r=0;r<_Volsteps;r++)
				{
					float3 p = from+s*i.pos*_Zoom;
					p = abs(_Tile - fmod(p, _Tile*2));
					float pa, a ;
					[loop]
					for (int i=0; i<_Iterations; i++)
					{
						p  =  abs(p) / dot(p,p) - _Formuparam;
						a  += abs(length(p) - pa);
						pa =  length(p);
					}
					float dm = max(0, _Darkmatter - pow(a, 2)*.001);
					a *= pow(a, 2);
					fade *= r > 6 ? 1-dm : 1;

					col  += float3(s, pow(s, 2), pow(s, 4))*a*_Brightness*fade;
					fade *= _Distfading;
					s    += _Stepsize;
				}
				col = lerp(length(col), col, _Saturation)*_Color*.02;
				return float4(col,1.);
			
			}

			// fragment shader
			float4 frag (v2f i) : SV_Target
			{
				float3 col=0;
				
				#ifdef _IS_STAR_ON
				col += renderstar(i);
				#endif
				
				#ifdef _IS_AURORA_ON
				col += renderaurora(i);
				#endif
				
				#ifdef _IS_BUILDING_ON
				col += renderbuildings(i)*.5;
				#endif
				
				#ifdef _IS_MOON_ON
				col += rendermoon(i);
				#endif
				
				#ifdef _IS_BLOOM_ON
				col = clamp(col, 0, 1);
				#endif
				
				return float4(col, 1.);
			}
			ENDCG
		}
	}
}
