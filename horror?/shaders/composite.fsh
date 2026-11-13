/* BLOOM */

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

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}


void main() {
    vec4 color;
	float depth;
    float ca_amount = CA + constantMood*0.01;
    vec2 rtexcoord = (texcoord-0.5)*(1.0 - ca_amount) + 0.5;
    vec2 btexcoord = (texcoord-0.5)*(1.0 + ca_amount) + 0.5;
    color = texture(colortex0, texcoord);
    color.b *= 0.1;
    if (currentPlayerHealth > 0.0) color.r *= 1.0 - (0.9 * pow(currentPlayerHealth, 1./2.));
    else color.r *= 0.11;
    color.r += texture(colortex0, rtexcoord).r;
    color.b += texture(colortex0, btexcoord).b;
	depth = pow(texture(depthtex0, texcoord).r, (100.1/max(float(worldDay) + float(worldTime)/24000 + constantMood*10.1, 0.01)) + float(isEyeInWater));

	color.rgb = mix(color.rgb, vec3(0.6), depth);

	color.rgb += vec3(random(texcoord * frameTimeCounter) - 0.5) * 0.3;

    gl_FragData[0] = color;
}
