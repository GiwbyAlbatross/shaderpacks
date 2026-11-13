/*
    Stems from XorDev's "Default Shaderpack"

    This was put together by @XorDev to make it easier for anyone to make their own shaderpacks in Minecraft (Optifine).
    You can do whatever you want with this code! Credit is not necessary, but always appreciated!

    You can find more information about shaders in Optfine here:
    https://github.com/sp614x/optifine/blob/master/OptiFineDoc/doc/shaders.txt

*/
//Declare GL version.
#version 120

//Get Entity id.
in vec2 mc_Entity;
//uniform int currentRenderedItemId;

//Model * view matrix and it's inverse.
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
// camera pos
uniform vec3 cameraPosition;
uniform vec3 playerLookVector;

// light positions
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform float sunAngle;
uniform bool hasCeiling;
uniform vec3 endFlashPosition;
uniform float endFlashIntensity;

// biome data
uniform float wetness;
uniform int biome_category;

// time
uniform float frameTimeCounter;

//Pass vertex information to fragment shader.
varying vec4 color;
varying vec2 coord0;
varying vec2 coord1;
varying vec3 normal_;
varying vec3 glpos;
out vec2 vEntity;


/* TODO:
 * - make particles fullbright (emissive)
 * - fix bloom in deferred.*sh #done
 * - ...
 */

void main()
{
    //Calculate world space position.
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;

    //Output diffuse and lightmap texture coordinates to fragment shader.
    coord1 = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy; // vec2(blocklight, ambientlight)

    int mcentity = int(mc_Entity.x);

    vEntity = vec2(mc_Entity);

    //Calculate view space normal.
    vec3 normal = gl_NormalMatrix * gl_Normal;
    if (((mcentity & 2) == 2) && (mcentity != -1)) { // CHECK FLAG 2: EMISSIVE
        color.rgb = vec3(1.0);
    } else {
        //Use flat for flat "blocks" or world space normal for solid blocks.
        normal = (mc_Entity.x==1) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(normal,0)).xyz;
        normal_ = normal;

        float sunriseyness =  max(1.0 / sunAngle, 1.0 / (sunAngle - 0.5));
        vec3 suncolour = mix(mix(vec3(1.0,1.0,0.9), vec3(1.0,0.85,0.7), clamp(sunriseyness, 0., 1.)), vec3(0.89, 0.9, 0.98), wetness);

        vec3 upsideDownNormal = normal;
        upsideDownNormal.x *= -1.0;
        upsideDownNormal.y *= -1.0;

        // Calculate simple lighting. Thanks to @PepperCode1
        float light = min(normal.x * normal.x * 0.6f + normal.y * normal.y * 0.25f * (3.0f + normal.y) + normal.z * normal.z * 0.8f, 1.0f);

        if ((biome_category == CAT_NETHER) || (biome_category == CAT_THE_END)) {
            color.rgb = vec3(light);
        } else {
            float sunlight = (1.0 + -(dot(sunPosition * 0.01, upsideDownNormal))) * 0.5;
            //sunlight *= clamp((vec4(sunPosition, 0.0) * 0.01 * gbufferModelView).y + 0.5, 0.4, 1.0);
            float monlight = (1.1 + -(dot(moonPosition * 0.01, upsideDownNormal))) * 0.4;
            //monlight *= clamp((vec4(moonPosition,0.0) * 0.01 * gbufferModelView).y + 0.6, 0.5, 1.0);
            color.rgb = mix(vec3(sunlight * suncolour + monlight * vec3(0.5, 0.7, 1.0)), vec3(light), coord1.x);
        }

        float endlight = (1.0 + -(dot(endFlashPosition*0.01, upsideDownNormal))) * 0.6 * endFlashIntensity;
        color.rgb += endlight * vec3(1., .0, 1.);
    }

    if (((mcentity == 5) || (mcentity == 7))) { // CHECK FLAG 3: WAVES
        // do waves (lava and water)
        pos.y += sin(pos.x + pos.z + frameTimeCounter/1.14591559026) * 0.1 - 0.05;
    }

    //Output position and fog to fragment shader.
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
    glpos = pos;

    //Output color with lighting to fragment shader.
    color *= gl_Color;
    //color.r = sin(normal.x);.
    //color.g = cos(normal.y);
    //color.b = tan(normal.z);

    coord0 = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
