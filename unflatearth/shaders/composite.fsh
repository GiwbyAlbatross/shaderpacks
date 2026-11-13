

#version 120

#define CA 0.01

uniform sampler2D colortex0;

uniform sampler2D depthtex0;

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

const vec3 ign = vec3(0.06711056f, 0.00583715f, 52.9829189f);

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

float onechannel_dither(float d, vec4 FRAGCOORD) {
    if (d < 0.001 || d < fract(ign.z * fract(dot(FRAGCOORD.xy, ign.xy)))) {
		return 0.0;
	}
    return 1.0;
}


void main() {
    vec4 color;
	//float depth;
    //float ca_amount = CA + constantMood*0.01;
    //vec2 rtexcoord = (texcoord-0.5)*(1.0 - ca_amount) + 0.5;
    //vec2 btexcoord = (texcoord-0.5)*(1.0 + ca_amount) + 0.5;
    color = texture(colortex0, texcoord);

    /*
    color.r = onechannel_dither(color.r, gl_FragCoord);
    color.g = onechannel_dither(color.g, gl_FragCoord);
    color.b = onechannel_dither(color.b, gl_FragCoord);
    color.a = 1.0;
    */

    gl_FragData[0] = color;
}
