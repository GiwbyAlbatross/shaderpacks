#version 120

#if defined IRIS_FEATURE_ENTITY_TRANSLUCENT && !defined IS_IRIS
#define OLD
#include "/lib/iris_required.glsl"
#elif !defined IS_IRIS
#include "/lib/iris_required.glsl"
#else

#define HDR // internally support overbright tones
//#define HDR_RAW // show the internal colours

uniform sampler2D texture;

varying vec4 color;
varying vec2 coord0;

void main()
{
    vec4 texsamp = texture2D(texture,coord0);

    #ifdef HDR
    #ifndef HDR_RAW
    texsamp.rgb /= 0.8;
    #endif
    #endif

    gl_FragData[0] = color * texsamp;
}
#endif
