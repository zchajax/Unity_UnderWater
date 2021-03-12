Shader "Custom/Ground"
{
    Properties
    {
        _Tess ("Tesselation", Range(1, 8)) = 4
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _NoiseScale ("Noise Scale", float) = 1
        _NoiseFrequency ("Noise Frequency", float) = 1
        _NoiseOffset ("Noise Offset", vector) = (0,0,0,0)
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows tessellate:tess vertex:vert

        #pragma target 5.0

        #include "Noise.cginc"

        sampler2D _MainTex;

        struct appdata
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
            float2 texcoord : TEXCOORD0;
        };

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Tess;
        float _NoiseScale;
        float _NoiseFrequency;
        float4 _NoiseOffset;

        
        float4 tess()
        {
            return _Tess;
        }

        void vert(inout appdata v)
        {
            float3 v0 = v.vertex.xyz;
            float3 binormal = cross(v.normal, v.tangent.xyz);
            float3 v1 = v0 + v.tangent.xyz * 0.01;
            float3 v2 = v0 +  binormal * 0.01;

            float noise0 = snoise((v0 + _NoiseOffset) * _NoiseFrequency) * _NoiseScale;
            v0 += noise0 * v.normal;
                
            float noise1 = snoise((v1 + _NoiseOffset) * _NoiseFrequency) * _NoiseScale;
            v1 += noise1 * v.normal;

            float noise2 = snoise((v2 + _NoiseOffset) * _NoiseFrequency) * _NoiseScale;
            v2 += noise2 * v.normal;

            v.normal = normalize(-cross(v2 - v0, v1 - v0));
            v.vertex.xyz = v0;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
