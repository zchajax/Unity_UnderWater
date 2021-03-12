Shader "PostProcessing/UnderWater"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseScale ("Noise Scale", float) = 1
        _NoiseFrequency ("Noise Frequency", float) = 1
        _NoiseSpeed ("Noise Speed", float) = 0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define PI 3.14159265359

            #include "UnityCG.cginc"
            #include "Noise.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
                
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            sampler2D _MainTex;

            float _NoiseScale;
            float _NoiseFrequency;
            float _NoiseSpeed;

            fixed4 frag (v2f i) : SV_Target
            {
                float noise = snoise(float3(i.screenPos.x, i.screenPos.y, _NoiseSpeed * _Time.x) * _NoiseFrequency);
                noise = (noise + 1) * 0.5;
                noise *= _NoiseScale;
                
                float4 uvOffset = normalize(float4(cos(noise * PI * 2), sin(noise * PI * 2), 0 , 0));

                fixed4 col = tex2Dproj(_MainTex, i.screenPos+ uvOffset * 0.01);

                //return fixed4(noise, noise, noise , 1);
                return col;
            }
            ENDCG
        }
    }
}
