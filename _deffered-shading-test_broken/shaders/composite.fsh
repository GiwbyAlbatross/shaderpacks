/* BLOOM */

#version 120

#define CA 0.01

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform float viewHeight;
uniform float viewWidth;

uniform float currentPlayerHealth;
uniform float constantMood;

uniform float frameTimeCounter;
uniform int worldDay;
uniform int worldTime;
uniform int isEyeInWater;

uniform mat4 gbufferProjectionInverse;

varying vec2 texcoord;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}


void main() {
    vec4 color;
    color = texture(colortex2, texcoord);
    gl_FragData[0] = color;
}
