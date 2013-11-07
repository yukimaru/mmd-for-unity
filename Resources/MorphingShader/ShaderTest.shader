/*
 * MMD Shader for Unity
 *
 * Copyright 2012 Masataka SUMI, Takahiro INOUE
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */
Shader "Debug/Shader Test"
{
	Properties
	{
		_Color("拡散色", Color) = (1,1,1,1)
		_SpecularColor("反射色", Color) = (1,1,1)
		_AmbColor("環境色", Color) = (1,1,1)
		_Shininess("反射強度", Float) = 0
		_OutlineColor("エッジ色", Color) = (0,0,0,1)
		_OutlineWidth("エッジ幅", Range(0,1)) = 0.2
		_MainTex("テクスチャ", 2D) = "white" {}
		_ToonTex("トゥーン", 2D) = "white" {}
		_SphereAddTex("スフィア（加算）", 2D) = "black" {}
		_SphereMulTex("スフィア（乗算）", 2D) = "white" {}
        _TextureSize ("Size", Range(0.0, 65536.0)) = 0
        _X1 ("name X", 2D) = "black" {}
        _Y1 ("name Y", 2D) = "black" {}
        _L1 ("name Length", 2D) = "black" {}
        _W1 ("name Weight", Range(0, 1)) = 0
	}

	SubShader
	{
		// Settings
		Tags
		{
			"ForceNoShadowCasting" = "True"
		}
		
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma glsl
            #include "UnityCG.cginc"
            #include "VertFragTest.cginc"
            ENDCG
        }

		// Surface Shader
		Cull Back
		CGPROGRAM
		#pragma surface surf MMD
		#include "MeshPmdMaterialSurface.cginc"
		ENDCG
		
		// Outline Pass
		Pass
		{
			Cull Front
			Lighting Off
			
			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "MeshPmdMaterialVertFrag.cginc"
			ENDCG
		}
	}

	// Other Environment
	Fallback "Diffuse"
}
