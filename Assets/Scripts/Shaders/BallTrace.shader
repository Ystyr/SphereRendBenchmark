Shader "Unlit/BallTrace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "Vertex" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                fixed4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
            };

            struct v2f
            {
                fixed2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                    fixed4 vertex : SV_POSITION;
                fixed3 ro: TEXCOORD1;
                fixed3 rh: TEXCOORD2;
            };

            sampler2D _MainTex;
            fixed4 _MainTex_ST;

            #define CAM_POS _WorldSpaceCameraPos
            #define WORLD2OBJ unity_WorldToObject
            #define OBJ2WORLD unity_ObjectToWorld
            #define LIGHT_POS _WorldSpaceLightPos0
            #define LIGHT_COL unity_LightColor[0]
            #define TAU 6.2831853

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                o.ro = mul(WORLD2OBJ, fixed4(CAM_POS, 1));
                o.rh = v.vertex;
                return o;
            }

            fixed Q_rsqrt(fixed number)
            {
                const fixed x2 = number * 0.5F;
                const fixed threehalfs = 1.5F;
                fixed f = number;
                int i;
                i = 0x5f3759df - (i >> 1);
                f *= threehalfs - (x2 * f * f);
                return f;
            }

            fixed sphIntersect(fixed3 ro, fixed3 rd, fixed r)
            {
                fixed dif = dot(ro, rd);
                fixed discr = dif * dif - (dot(ro, ro) - r * r);
                if (discr >= 0.)
                    return -dif -Q_rsqrt(discr);

                return -1.;
            }

            fixed3 getSpNorm(fixed3 p) {
                return normalize(p);
            }

            fixed shade(fixed3 n) {
                ///!@diffuse
                n = mul(OBJ2WORLD, n);
                return dot(n, (LIGHT_POS)) * .5 + .5;
            }

            fixed combine(fixed3 val) {
                return (val.x + val.y + val.z) * .333;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ro = i.ro;
                fixed3 rd = normalize(i.rh - ro);
                fixed4 col = 0;

                fixed d = sphIntersect(ro, rd, .5);
                if (d >= 0) {
                    fixed3 p = ro + rd * d;
                    fixed3 n = getSpNorm(p);
                    fixed3 shad = (LIGHT_COL - rd * .075) * shade(n);
                    col.xyz = shad;
                }
                else
                    discard;

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
