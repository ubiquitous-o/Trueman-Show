
// Copyright (c) 2021 @yossy222_VRC
// Released under the MIT license
// https://opensource.org/licenses/mit-license.php

// Original Code by
// <Booth>
// Star Nest Shader HLSL by @Feyris77
// https://voxelgummi.booth.pm/items/1121090
// "Morning City" by Devin | Shadertoy
// https://www.shadertoy.com/view/XsBSRG

Shader "Skybox/NightCity"
{
	Properties
	{
		[Header(Building)]
		[IntRange]_Buildings("Buildings (int)", Range(0, 200)) = 100
		[HDR]_WindowColorNear("Window Color Near", Color) = (3, 2, 1, 1)
		[HDR]_WindowColorFar("Window Color Far", Color) = (3, 3, 6, 1)

		[Header(ViewPoint)]
		_CameraPosition("Camera Position", Range(5, 30)) = 10
		_CameraDirection("Camera Direction", Range(-1, 1)) = -0.5

		[Header(Car)]
		[Toggle(_IS_CARS_ON)] _Cars("Cars On", Float) = 1
		_CarColorLeft("Car Color Left", Color) = (0.5, 0.5, 1.0, 1)
		_CarColorRight("Car Color Right", Color) = (1.0, 0.1, 0.1, 1)

		[Header(Star)]
		[Toggle(_IS_STAR_ON)] _Stars("Stars On", Float) = 1
		[HDR]_StarColor("Star Color", Color) = (0.1622019, 0.1740361, 0.4245283, 1)
	}

	SubShader
	{
		Tags 
		{
			"RenderType" = "Background"
			"Queue" = "Background"
			"PreviewType" = "SkyBox"
		}

		Pass
		{
			ZWrite Off
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature _IS_CARS_ON
			#pragma shader_feature _IS_STAR_ON
			#include "UnityCG.cginc"

			float4 vec4(float x,float y,float z,float w) { return float4(x,y,z,w); }
			float4 vec4(float x) { return float4(x,x,x,x); }
			float4 vec4(float2 x,float2 y) { return float4(float2(x.x,x.y),float2(y.x,y.y)); }
			float4 vec4(float3 x,float y) { return float4(float3(x.x,x.y,x.z),y); }

			float3 vec3(float x,float y,float z) { return float3(x,y,z); }
			float3 vec3(float x) { return float3(x,x,x); }
			float3 vec3(float2 x,float y) { return float3(float2(x.x,x.y),y); }

			float2 vec2(float x,float y) { return float2(x,y); }
			float2 vec2(float x) { return float2(x,x); }

			float vec(float x) { return float(x); }

			int _Buildings;
			float4 _WindowColorNear;
			float4 _WindowColorFar;
			float _CameraPosition;
			float _CameraDirection;
			float4 _CarColorLeft;
			float4 _CarColorRight;
			int _Stars;
			float4 _StarColor;

			struct VertexInput {
				float4 vertex : POSITION;
				float3 uv:TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				//VertexInput
			};

			struct VertexOutput {
				float4 vertex : SV_POSITION;
				float3 uv : TEXCOORD0;
				float3 pos : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
				//VertexOutput
			};

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.pos = normalize(mul(unity_ObjectToWorld, v.vertex.xyz));
				o.uv = v.uv;
				return o;
			}

			float rand(float2 n) {
				return frac(sin((n.x*1e2 + n.y*1e4 + 1475.4526)*1e-4)*1e6);
			}

			float noise(float2 p)
			{
				p = floor(p*200.0);
				return rand(p);
			}

			float3 polygonXY(float z,float2 vert1, float2 vert2, float3 camPos,float3 rayDir) {
				float t = -(camPos.z - z) / rayDir.z;
				float2 cross = camPos.xy + rayDir.xy*t;
				if (cross.x > min(vert1.x,vert2.x) &&
					cross.x<max(vert1.x,vert2.x) &&
					cross.y>min(vert1.y,vert2.y) &&
					cross.y<max(vert1.y,vert2.y) &&
					dot(rayDir,vec3(cross,z) - camPos)>0.0) {
						float dist = length(camPos - vec3(cross,z));
						return vec3(dist, cross.x - min(vert1.x,vert2.x),cross.y - min(vert1.y,vert2.y));
					}

				return vec3(101.0,0.0,0.0);
			}

			float3 polygonYZ(float x,float2 vert1, float2 vert2, float3 camPos,float3 rayDir) {
				float t = -(camPos.x - x) / rayDir.x;
				float2 cross1 = camPos.yz + rayDir.yz*t;
				if (cross1.x > min(vert1.x,vert2.x) &&
					cross1.x<max(vert1.x,vert2.x) &&
					cross1.y>min(vert1.y,vert2.y) &&
					cross1.y<max(vert1.y,vert2.y) &&
					dot(rayDir,vec3(x,cross1) - camPos)>0.0) {
						float dist = length(camPos - vec3(x,cross1));
						return vec3(dist, cross1.x - min(vert1.x,vert2.x),cross1.y - min(vert1.y,vert2.y));
					}

				return vec3(101.0,0.0,0.0);
			}

			float3 polygonXZ(float y,float2 vert1, float2 vert2, float3 camPos,float3 rayDir) {
				float t = -(camPos.y - y) / rayDir.y;
				float2 cross1 = camPos.xz + rayDir.xz*t;
				if (cross1.x > min(vert1.x,vert2.x) &&
					cross1.x<max(vert1.x,vert2.x) &&
					cross1.y>min(vert1.y,vert2.y) &&
					cross1.y<max(vert1.y,vert2.y) &&
					dot(rayDir,vec3(cross1.x,y,cross1.y) - camPos)>0.0) {
						float dist = length(camPos - vec3(cross1.x,y,cross1.y));
						return vec3(dist, cross1.x - min(vert1.x,vert2.x),cross1.y - min(vert1.y,vert2.y));
					}

				return vec3(101.0,0.0,0.0);
			}

			float3 tex2DWall(float2 pos, float2 maxPos, float2 squarer,float s,float height,float dist,float3 rayDir,float3 norm) {
				float randB = rand(squarer*2.0);
				float3 windowColor = (-0.4 + randB * 0.8)*vec3(0.3,0.3,0.0) + (-0.4 + frac(randB*10.0)*0.8)*vec3(0.0,0.0,0.3) + (-0.4 + frac(randB*10000.0)*0.8)*vec3(0.3,0.0,0.0);
				float floorFactor = 1.0;
				float2 windowSize = vec2(0.65,0.35);
				float3 wallColor = s * (0.3 + 1.4*frac(randB*100.0))*vec3(0.1,0.1,0.1) + (-0.7 + 1.4*frac(randB*1000.0))*vec3(0.02,0.,0.);
				wallColor *= 1.3;

				float3 color = vec3(0.0);
				float3 conturColor = wallColor / 1.5;
				if (height < 0.51) {
					windowColor += _WindowColorNear.xyz;
					windowSize = vec2(0.4,0.4);
					floorFactor = 0.0;

				}
				if (height <= 0.85) {
					windowColor += _WindowColorNear.xyz - 0.1;
					windowSize = vec2(0.3, 0.3);
					floorFactor = 0.0;
				}
				if (height < 0.6) { floorFactor = 1.0; }
				if (height > 0.85) {
					windowColor += _WindowColorFar.xyz;
				}
				windowColor *= 3.5;
				float wsize = 0.02;
				wsize += -0.007 + 0.014*frac(randB*75389.9365);
				windowSize += vec2(0.34*frac(randB*45696.9365),0.50*frac(randB*853993.5783));

				float2 contur = vec2(0.0) + (frac(maxPos / 2.0 / wsize))*wsize;
				if (contur.x < wsize) { contur.x += wsize; }
				if (contur.y < wsize) { contur.y += wsize; }

				float2 winPos = (pos - contur) / wsize / 2.0 - floor((pos - contur) / wsize / 2.0);

				float numWin = floor((maxPos - contur) / wsize / 2.0).x;

				if ((maxPos.x > 0.5&&maxPos.x < 0.6) && (((pos - contur).x > wsize*2.0*floor(numWin / 2.0)) && ((pos - contur).x < wsize*2.0 + wsize * 2.0*floor(numWin / 2.0)))) {
						return (0.9 + 0.2*noise(pos))*conturColor;
				}

				if ((maxPos.x > 0.6&&maxPos.x < 0.7) && ((((pos - contur).x > wsize*2.0*floor(numWin / 3.0)) && ((pos - contur).x < wsize*2.0 + wsize * 2.0*floor(numWin / 3.0))) ||
														(((pos - contur).x > wsize*2.0*floor(numWin*2.0 / 3.0)) && ((pos - contur).x < wsize*2.0 + wsize * 2.0*floor(numWin*2.0 / 3.0))))) {
						return (0.9 + 0.2*noise(pos))*conturColor;
				}

				if ((maxPos.x > 0.7) && ((((pos - contur).x > wsize*2.0*floor(numWin / 4.0)) && ((pos - contur).x < wsize*2.0 + wsize * 2.0*floor(numWin / 4.0))) ||
														(((pos - contur).x > wsize*2.0*floor(numWin*2.0 / 4.0)) && ((pos - contur).x < wsize*2.0 + wsize * 2.0*floor(numWin*2.0 / 4.0))) ||
														(((pos - contur).x > wsize*2.0*floor(numWin*3.0 / 4.0)) && ((pos - contur).x < wsize*2.0 + wsize * 2.0*floor(numWin*3.0 / 4.0))))) {
						return (0.9 + 0.2*noise(pos))*conturColor;
				}
				if ((maxPos.x - pos.x < contur.x) || (maxPos.y - pos.y < contur.y + 2.0*wsize) || (pos.x < contur.x) || (pos.y < contur.y)) {
						return (0.9 + 0.2*noise(pos))*conturColor;

				}
				if (maxPos.x < 0.14) {
						return (0.9 + 0.2*noise(pos))*wallColor;
				}

				float2 window = floor((pos - contur) / wsize / 2.0);
				float random = rand(squarer*s*maxPos.y + window);
				float randomZ = rand(squarer*s*maxPos.y + floor(vec2((pos - contur).y,(pos - contur).y) / wsize / 2.0));
				float windows = floorFactor * sin(randomZ*5342.475379 + (frac(975.568*randomZ)*0.15 + 0.05)*window.x);

				float blH = 0.06*dist*600.0 / 1 / abs(dot(normalize(rayDir.xy),normalize(norm.xy)));
				float blV = 0.06*dist*600.0 / 1 / sqrt(abs(1.0 - pow(abs(rayDir.z),2.0)));

				windowColor += vec3(1.0,1.0,1.0);
				windowColor += dist + vec3(rand(squarer * 20), rand(squarer * 20), rand(squarer * 20)); // adjust
				windowColor *= smoothstep(0.5 - windowSize.x / 2.0 - blH,0.5 - windowSize.x / 2.0 + blH,winPos.x);
				windowColor *= smoothstep(0.5 + windowSize.x / 2.0 + blH,0.5 + windowSize.x / 2.0 - blH,winPos.x);
				windowColor *= smoothstep(0.5 - windowSize.y / 2.0 - blV,0.5 - windowSize.y / 2.0 + blV,winPos.y);
				windowColor *= smoothstep(0.5 + windowSize.y / 2.0 + blV,0.5 + windowSize.y / 2.0 - blV,winPos.y);

				if ((random < 0.05*(3.5 - 2.5*floorFactor)) || (windows > 0.65)) {
						if (winPos.y < 0.5) { windowColor *= (1.0 - 0.4*frac(random*100.0)); }
						if ((winPos.y > 0.5) && (winPos.x < 0.5)) { windowColor *= (1.0 - 0.4*frac(random*10.0)); }
						return (0.9 + 0.2*noise(pos))*wallColor + (0.9 + 0.2*noise(pos))*windowColor;


				}
				else {
					windowColor *= 0.08*frac(10.0*random);
				}
				return (0.9 + 0.2*noise(pos))*wallColor*windowColor;
			}
			// tex2DWall()


			float3 tex2DRoof(float2 pos, float2 maxPos,float2 squarer) {
				float wsize = 0.025;
				float randB = rand(squarer*2.0);
				float3 wallColor = (0.3 + 1.4*frac(randB*100.0))*vec3(0.1,0.1,0.1) + (-0.7 + 1.4*frac(randB*1000.0))*vec3(0.02,0.,0.);
				float3 conturColor = wallColor * 1.5 / 2.5;
				float2 contur = vec2(0.02);
				if ((maxPos.x - pos.x < contur.x) || (maxPos.y - pos.y < contur.y) || (pos.x < contur.x) || (pos.y < contur.y)) {
						return (0.9 + 0.2*noise(pos))*conturColor;

				}
				float step1 = 0.06 + 0.12*frac(randB*562526.2865);
				pos -= step1;
				maxPos -= step1 * 2.0;
				if ((pos.x > 0.0&&pos.y > 0.0&&pos.x < maxPos.x&&pos.y < maxPos.y) && ((abs(maxPos.x - pos.x) < contur.x) || (abs(maxPos.y - pos.y) < contur.y) || (abs(pos.x) < contur.x) || (abs(pos.y) < contur.y))) {
						return (0.9 + 0.2*noise(pos))*conturColor;

				}
				pos -= step1;
				maxPos -= step1 * 2.0;
				if ((pos.x > 0.0&&pos.y > 0.0&&pos.x < maxPos.x&&pos.y < maxPos.y) && ((abs(maxPos.x - pos.x) < contur.x) || (abs(maxPos.y - pos.y) < contur.y) || (abs(pos.x) < contur.x) || (abs(pos.y) < contur.y))) {
						return (0.9 + 0.2*noise(pos))*conturColor;

				}
				pos -= step1;
				maxPos -= step1 * 2.0;
				if ((pos.x > 0.0&&pos.y > 0.0&&pos.x < maxPos.x&&pos.y < maxPos.y) && ((abs(maxPos.x - pos.x) < contur.x) || (abs(maxPos.y - pos.y) < contur.y) || (abs(pos.x) < contur.x) || (abs(pos.y) < contur.y))) {
						return (0.9 + 0.2*noise(pos))*conturColor;

				}

				return (0.9 + 0.2*noise(pos))*wallColor;
			}
			// tex2DRoof()


			float3 cars(float2 squarer, float2 pos, float dist,float level) {
				float3 color = vec3(0.0);
				float carInten = 3.5 / sqrt(dist);
				float carRadis = 0.01;
				if (dist > 2.0) { carRadis *= sqrt(dist / 2.0); }
				float3 car1 = _CarColorLeft.rgb;
				float3 car2 = _CarColorRight.rgb;
				float carNumber = 0.5;

				float random = noise((level + 1.0)*squarer*1.24435824);
				for (int j = 0;j < 10; j++) {
					float i = 0.03 + float(j)*0.094;
					if (frac(random*5.0 / i) > carNumber) { color += car1 * carInten*smoothstep(carRadis,0.0,length(pos - vec2(frac(i + _Time.y / 4.0),0.025))); }

					if (frac(random*10.0 / i) > carNumber) { color += car2 * carInten*smoothstep(carRadis,0.0,length(pos - vec2(frac(i - _Time.y / 4.0),0.975))); }
					if (color.x > 0.0) break;
				}
				for (int k = 0;k < 10; k++) {
					float i = 0.03 + float(k)*0.094;
					if (frac(random*5.0 / i) > carNumber) { color += car2 * carInten*smoothstep(carRadis,0.0,length(pos - vec2(0.025,frac(i + _Time.y / 4.0)))); }
					if (frac(random*10.0 / i) > carNumber) { color += car1 * carInten*smoothstep(carRadis,0.0,length(pos - vec2(0.975,frac(i - _Time.y / 4.0)))); }
						if (color.x > 0.0) break;

				}
				for (int l = 0;l < 10; l++) {
					float i = 0.03 + 0.047 + float(l)*0.094;
					if (frac(random*100.0 / i) > carNumber) { color += car1 * carInten*smoothstep(carRadis,0.0,length(pos - vec2(frac(i + _Time.y / 4.0),0.045))); }
					if (frac(random*1000.0 / i) > carNumber) { color += car2 * carInten*smoothstep(carRadis,0.0,length(pos - vec2(frac(i - _Time.y / 4.0),0.955))); }
						if (color.x > 0.0) break;

				}
				for (int m = 0;m < 10; m++) {
					float i = 0.03 + 0.047 + float(m)*0.094;
					if (frac(random*100.0 / i) > carNumber) { color += car2 * carInten*smoothstep(carRadis,0.0,length(pos - vec2(0.045,frac(i + _Time.y / 4.0)))); }
					if (frac(random*1000.0 / i) > carNumber) { color += car1 * carInten*smoothstep(carRadis,0.0,length(pos - vec2(0.955,frac(i - _Time.y / 4.0)))); }
						if (color.x > 0.0) break;

				}
				return color;
			}
			// cars()


			float3 tex2DGround(float2 squarer, float2 pos,float2 vert1,float2 vert2,float dist) {
				float3 color = (0.9 + 0.2*noise(pos))*vec3(0.1,0.15,0.1);
				float randB = rand(squarer*2.0);

				float3 wallColor = (0.3 + 1.4*frac(randB*100.0))*vec3(0.1,0.1,0.1) + (-0.7 + 1.4*frac(randB*1000.0))*vec3(0.02,0.,0.);
				float fund = 0.03;
				float bl = 0.01;
				float f = smoothstep(vert1.x - fund - bl,vert1.x - fund,pos.x);
				f *= smoothstep(vert1.y - fund - bl,vert1.y - fund,pos.y);
				f *= smoothstep(vert2.y + fund + bl,vert2.y + fund,pos.y);
				f *= smoothstep(vert2.x + fund + bl,vert2.x + fund,pos.x);

				pos -= 0.0;
				float2 maxPos = vec2(1.,1.);
				float2 contur = vec2(0.06,0.06);
				if ((pos.x > 0.0&&pos.y > 0.0&&pos.x < maxPos.x&&pos.y < maxPos.y) && ((abs(maxPos.x - pos.x) < contur.x) || (abs(maxPos.y - pos.y) < contur.y) || (abs(pos.x) < contur.x) || (abs(pos.y) < contur.y))) {
						color = vec3(0.1,0.1,0.1)*(0.9 + 0.2*noise(pos));

				}
				pos -= 0.06;
				maxPos = vec2(.88,0.88);
				contur = vec2(0.01,0.01);
				if ((pos.x > 0.0&&pos.y > 0.0&&pos.x < maxPos.x&&pos.y < maxPos.y) && ((abs(maxPos.x - pos.x) < contur.x) || (abs(maxPos.y - pos.y) < contur.y) || (abs(pos.x) < contur.x) || (abs(pos.y) < contur.y))) {
						color = vec3(0.,0.,0.);

				}
				color = lerp(color,(0.9 + 0.2*noise(pos))*wallColor*1.5 / 2.5,f);

				pos += 0.06;

				#ifdef _IS_CARS_ON
					if (pos.x<0.07 || pos.x>0.93 || pos.y<0.07 || pos.y>0.93) {
						color += cars(squarer,pos,dist,0.0);
					}
				#endif

				return color;
			}
			// tex2DGround()

			float3 city(VertexOutput vertex_output) {

				// http://wordpress.notargs.com/blog/blog/2015/11/08/unity%E8%87%AA%E4%BD%9C%E3%81%AEskybox%E3%81%A7%E3%82%B8%E3%83%A5%E3%83%AA%E3%82%A2%E9%9B%86%E5%90%88%E3%81%AB%E5%9B%B2%E3%81%BE%E3%82%8C%E3%82%8B/
				float3 pos = vertex_output.uv;
				pos = float3(atan2(pos.x, pos.z), atan2(pos.y, length(pos.xz)), length(pos));

				float t = _CameraPosition; //-_Time.y;
				float tt = t - _CameraDirection; //-_Time.y-0.5;

				float3 camPos = vec3(5.*t, 4.1*t, 2.1);
				float3 camTarget = vec3(5.*tt, 3.1*tt, 2.7);


				float3 camDir = normalize(camTarget - camPos);
				float3 camUp = normalize(vec3(0.0, 0.0, -1.0));
				float3 camSide = cross(camDir, camUp);
				camUp = cross(camDir, camSide);
				float3 rayDir = normalize(camSide*pos.x + camUp * pos.y + camDir * 1.6);
				float angle = 0.03*pow(abs(acos(rayDir.x)), 4.0);
				//angle = min(0.0,angle);
				float3 color = vec3(0.0);
				float2 square = floor(camPos.xy);
				square.x += 0.5 - 0.5*sign(rayDir.x);
				square.y += 0.5 - 0.5*sign(rayDir.y);
				float mind = 100.0;
				int k = 0;
				float3 pol;
				float2 maxPos;
				float2 crossG;
				float tSky = -(camPos.z - 3.9) / rayDir.z;
				float2 crossSky = floor(camPos.xy + rayDir.xy*tSky);

				for (int i = 1; i < _Buildings; i++) {

					float2 squarer = square - vec2(0.5, 0.5) + 0.5*sign(rayDir.xy);

					if ((crossSky.x == squarer.x && crossSky.y == squarer.y) &&
						(crossSky.x != floor(camPos.x) || crossSky.y != floor(camPos.y)))
					{
						color += vec3(vec2(0.0, 0.0)*abs(angle)*exp(-rayDir.z*rayDir.z*30.0), 0.2);
						break;

					}
					float t;
					float random = rand(squarer);
					float height = 0.0;
					float quartalR = rand(floor(squarer / 10.0));
					if (floor(squarer.x / 10.0) == 0.0 && floor(squarer.y / 10.0) == 0.0) { quartalR = 0.399; }
					if (quartalR < 0.4) {
						height = -0.15 + 0.4*random + smoothstep(12.0, 7.0, length(frac(squarer / 10.0)*10.0 - vec2(5.0, 5.0)))*0.8*random + 0.9*smoothstep(10.0, 0.0, length(frac(squarer / 10.0)*10.0 - vec2(5.0, 5.0)));
						height *= quartalR / 0.4;
					}
					float maxJ = 2.0;
					float roof = 1.0;
					if (height < 0.3) {
						height = 0.3*(0.7 + 1.8*frac(random*100.543264));maxJ = 2.0;
						if (frac(height*1000.0) < 0.04) height *= 1.3;
					}
					if (height > 0.5) { maxJ = 3.0; }
					if (height > 0.85) { maxJ = 4.0; }
					if (frac(height*100.0) < 0.15) { height = pow(maxJ - 1.0, 0.3)*height; maxJ = 2.0; roof = 0.0; }


					float maxheight = 1.5*pow((maxJ - 1.0), 0.3)*height + roof * 0.07;
					if (camPos.z + rayDir.z*(length(camPos.xy - square) + 0.71 - sign(rayDir.z)*0.71) / length(rayDir.xy) < maxheight) {
						float2 vert1r;
						float2 vert2r;
						float zz = 0.0;
						float prevZZ = 0.0;
						[unroll(100)]
						for (int nf = 1;nf < 8;nf++) {
							float j = float(nf);
							if (j > maxJ) { break; }
							prevZZ = zz;
							zz = 1.5*pow(j, 0.3)*height;
							//prevZZ = zz-0.8;

							float dia = 1.0 / pow(j, 0.3);
							if (j == maxJ) {
								if (roof == 0.0) { break; }
								zz = 1.5*pow((j - 1.0), 0.3)*height + 0.03 + 0.04*frac(random*1535.347);
								dia = 1.0 / float(pow((j - 1.0), 0.3) - 0.2 - 0.2*frac(random*10000.0));
							}

							float2 v1 = vec2(0.0);//vec2(random*10.0,random*1.0);
							float2 v2 = vec2(0.0);//vec2(random*1000.0,random*100.0);
							float randomF = frac(random*10.0);
							if (randomF < 0.25) { v1 = vec2(frac(random*1000.0), frac(random*100.0)); }
							if (randomF > 0.25&&randomF < 0.5) { v1 = vec2(frac(random*100.0), 0.0);v2 = vec2(0.0, frac(random*1000.0)); }
							if (randomF > 0.5&&randomF < 0.75) { v2 = vec2(frac(random*1000.0), frac(random*100.0)); }
							if (randomF > 0.75) { v1 = vec2(0.0, frac(random*1000.0)); v2 = vec2(frac(random*100.0), 0.0); }
							if (rayDir.y < 0.0) {
								float y = v1.y;
								v1.y = v2.y;
								v2.y = y;
							}
							if (rayDir.x < 0.0) {
								float x = v1.x;
								v1.x = v2.x;
								v2.x = x;
							}

							float2 vert1 = square + sign(rayDir.xy)*(0.5 - 0.37*(dia*1.0 - 1.0*v1));
							float2 vert2 = square + sign(rayDir.xy)*(0.5 + 0.37*(dia*1.0 - 1.0*v2));
							if (j == 1.0) {
								vert1r = vec2(min(vert1.x, vert2.x), min(vert1.y, vert2.y));
								vert2r = vec2(max(vert1.x, vert2.x), max(vert1.y, vert2.y));
							}

							float3 pxy = polygonXY(zz, vert1, vert2, camPos, rayDir);
							if (pxy.x < mind) { mind = pxy.x; pol = pxy; k = 1;maxPos = vec2(abs(vert1.x - vert2.x), abs(vert1.y - vert2.y)); }

							float3 pyz = polygonYZ(vert1.x, vec2(vert1.y, prevZZ), vec2(vert2.y, zz), camPos, rayDir);
							if (pyz.x < mind) { mind = pyz.x; pol = pyz; k = 2;maxPos = vec2(abs(vert1.y - vert2.y), zz - prevZZ); }

							float3 pxz = polygonXZ(vert1.y, vec2(vert1.x, prevZZ), vec2(vert2.x, zz), camPos, rayDir);
							if (pxz.x < mind) { mind = pxz.x; pol = pxz; k = 3;maxPos = vec2(abs(vert1.x - vert2.x), zz - prevZZ); }


						}

						if ((mind < 100.0) && (k == 1)) {
							color += tex2DRoof(vec2(pol.y, pol.z), maxPos, squarer);
							if (mind > 3.0) { color *= sqrt(3.0 / mind); }

							break;
						}
						if ((mind < 100.0) && (k == 2)) {
							color += tex2DWall(vec2(pol.y, pol.z), maxPos, squarer, 1.2075624928, height, mind, rayDir, vec3(1.0, 0.0, 0.0));
							if (mind > 3.0) { color *= sqrt(3.0 / mind); }
							break;
						}

						if ((mind < 100.0) && (k == 3)) {
							color += tex2DWall(vec2(pol.y, pol.z), maxPos, squarer, 0.8093856205, height, mind, rayDir, vec3(0.0, 1.0, 0.0));
							if (mind > 3.0) { color *= sqrt(3.0 / mind); }

							break;
						}
						t = -camPos.z / rayDir.z;
						crossG = camPos.xy + rayDir.xy*t;
						if (floor(crossG.x) == squarer.x && floor(crossG.y) == squarer.y)
						{
							mind = length(vec3(crossG, 0.0) - camPos);
							color += tex2DGround(squarer, frac(crossG), frac(vert1r), frac(vert2r), mind);
							if (mind > 3.0) { color *= sqrt(3.0 / mind); }

							break;
						}

					}

					if ((square.x + sign(rayDir.x) - camPos.x) / rayDir.x < (square.y + sign(rayDir.y) - camPos.y) / rayDir.y) {
						square.x += sign(rayDir.x)*1.0;
					}
					else {
						square.y += sign(rayDir.y)*1.0;
					}

					if (i == _Buildings - 1 && rayDir.z > -0.1) {
						color += vec3(vec2(0.0, 0.0)*abs(angle)*exp(-rayDir.z*rayDir.z*30.0), 0.2); 
					}

				}

				return color;
			}

			fixed3 star(VertexOutput vertex_output)
			{
				if (vertex_output.pos.y < -0.2) {
					return 0;
				}

				float3 from = float3(46, 487, 3534) + _Time.x * float3(0.05, 0.05, 0.2);
				float s = .1, fade = 0.116;
				float3 col;

				[loop]
				for (int r = 0;r < 4;r++)
				{
					float3 p = from + s * vertex_output.pos*3;
					p = abs(1 - fmod(p, 1 * 2));
					float pa, a;
					[loop]
					for (int l = 0; l < 9; l++)
					{
						p = abs(p) / dot(p, p) - 0.679;
						a += abs(length(p) - pa);
						pa = length(p);
					}
					float dm = max(0, 0.33 - pow(a, 2)*.001);
					a *= pow(a, 2);
					fade *= r > 6 ? 1 - dm : 1;

					col += float3(s, pow(s, 2), pow(s, 4))*a*0.01*fade;
					fade *= 0.445;
					s += 0.205;
				}
				col = lerp(length(col), col, 0.744)*_StarColor*.02;
				return col;

			} // star()


			fixed4 frag(VertexOutput vertex_output) : SV_Target {
				float3 color = 0;
				color += city(vertex_output);

				#ifdef _IS_STAR_ON
				color += star(vertex_output);
				#endif

				return vec4( color, 1.0);
			}
			// frag()


			ENDCG
		}
	}
}
