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

 /*
 * Morphing Shader
 *
 * Copyright 2013 Eiichi Takebuchi(GRGSIBERIA)
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

float4 _Color;
float _Opacity;
float4 _OutlineColor;
float _OutlineWidth;

sampler2D _MainTex;
float _TextureSize;
sampler2D _X1;
sampler2D _Y1;
sampler2D _L1;
float _W1;

struct v2f
{
	float4 pos : SV_POSITION;
	float2 uv  : TEXCOORD0;
	float3 color : COLOR0;
};

// Colorに圧縮したfloatを戻す
float UnpackFloat4(float4 _packed) {
    float4 rgba = _packed * 255;
                
    float sign = step(-128.0, -rgba.y) * 2.0 - 1.0;
    float exponent = rgba.x - 127.0;
            
    if (abs(exponent - 127.0) < 0.001)
        return 0.0;
            
    float mantissa = fmod(rgba.x, 128.0) * 65536.0 + rgba.z * 256.0 + rgba.w + (0x800000);
    return sign * exp2(exponent - 23.0) * mantissa;
}

inline int ColorToInt(float4 argb) {
    float unpacked_float = UnpackFloat4(argb);
    return (int)unpacked_float;
}

// 頂点インデックスからテクスチャを参照するUV座標を取得する
inline float4 IndexToUV(int id, int size) {
    float uu = (id % size) / size;
    float vv = (id / size) / size;
    return float4(uu, vv, 0, 0);
}

// テクスチャを参照してUnpackされたデータを取り出す
inline float GetData(sampler2D _texture, float4 uv) {
    float4 rgba = tex2Dlod(_texture, uv);
    return UnpackFloat4(rgba);
}
            
// sqrt(x^2 + y^2 + z^2) = 1
// x^2 + y^2 + z^2 = 1
// x^2 + y^2 = 1 - z^2
// -z^2 = x^2 + y^2 - 1
//  z^2 =-x^2 - y^2 + 1
float4 GetDirection(sampler2D _x, sampler2D _y, sampler2D _len, float4 _uv) {
    float xxx = GetData(_x, _uv);
    float yyy = GetData(_y, _uv);
    float zzz = xxx * xxx - yyy * yyy + 1.0;
    float len = GetData(_len, _uv);
    return float4(xxx, yyy, sqrt(zzz), 0) * len;
}
            
inline float4 MixingDirection(appdata_full v) {
    int id = ColorToInt(v.color);
    int size = (int)_TextureSize;
    float4 _uv = IndexToUV(id, size);

    return GetDirection(_X1, _Y1, _L1, _uv) * _W1;
}

v2f vert( appdata_full v )
{
	v2f o;
	v.vertex += MixingDirection(v);
	float4 pos = mul( UNITY_MATRIX_MVP, v.vertex );
	float width = 0.01 * _OutlineWidth;
	float4 edge_pos = v.vertex + pos.w * width * float4( v.normal, 0.0 );
	o.pos = mul( UNITY_MATRIX_MVP, edge_pos );

	return o;
}
half4 frag( v2f i ) : COLOR
{
	return half4( _OutlineColor.rgb, _Opacity );
}
