/* BLOOM */

#version 120

//#define VIEW_BLOOM_ONLY // show bloom directly rather than composited
#define BLOOM // bright parts of the image bloom. Tanks performance a bit...
uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform float viewHeight;
uniform float viewWidth;

uniform bool hasSkylight;

uniform mat4 gbufferProjectionInverse;

varying vec2 texcoord;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

// literally copy-pasted from GhSoares on godotshaders.com https://godotshaders.com/shader/bloom-post-processing-for-viewports/

const float bloomRadius = 0.25; // changed uniform to const
const float bloomThreshold = 1.5; // [0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3] threshold for bloom
const float bloomIntensity = 1.5; // [0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3] intensity of bloom in dimensions without skylight

const float bloomIntensitySkyLightDimension = 0.4; // [0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2]

const float bloomdetail = 4;

// TODO (giwby): fix this to use lightness as threshold except R channel for redstone_[wall_]torch
vec3 GetBloomPixel(sampler2D tex, vec2 uv, vec2 texPixelSize) {

	vec2 uv2 = floor(uv / texPixelSize) * texPixelSize;
	uv2 += texPixelSize * .001;
	vec3 tl = max(textureLod(tex, uv2, 4.).rgb - bloomThreshold, 0.0); // changed texture(...) to textureLod(..., 4.)
	vec3 tr = max(textureLod(tex, uv2 + vec2(texPixelSize.x, 0.0), 4.).rgb - bloomThreshold, 0.0);
	vec3 bl = max(textureLod(tex, uv2 + vec2(0.0, texPixelSize.y), 4.).rgb - bloomThreshold, 0.0);
	vec3 br = max(textureLod(tex, uv2 + vec2(texPixelSize.x, texPixelSize.y), 4.).rgb - bloomThreshold, 0.0);
	vec2 f = fract( uv / texPixelSize );

	vec3 tA = mix( tl, tr, f.x );
	vec3 tB = mix( bl, br, f.x );

	return mix( tA, tB, f.y );
}

vec3 GetBloom(sampler2D tex, vec2 uv, vec2 texPixelSize) {
	vec3 bloom = vec3(0.0);
	vec2 off = vec2(1) * texPixelSize * bloomRadius;
	bloom += GetBloomPixel(tex, uv + off * vec2(-1, -1), texPixelSize * bloomRadius) * 0.292893;
	bloom += GetBloomPixel(tex, uv + off * vec2(-1, 0), texPixelSize * bloomRadius) * 0.5;
	bloom += GetBloomPixel(tex, uv + off * vec2(-1, 1), texPixelSize * bloomRadius) * 0.292893;
	bloom += GetBloomPixel(tex, uv + off * vec2(0, -1), texPixelSize * bloomRadius) * 0.5;
	bloom += GetBloomPixel(tex, uv + off * vec2(0, 0), texPixelSize * bloomRadius) * 1.0;
	bloom += GetBloomPixel(tex, uv + off * vec2(0, 1), texPixelSize * bloomRadius) * 0.5;
	bloom += GetBloomPixel(tex, uv + off * vec2(1, -1), texPixelSize * bloomRadius) * 0.292893;
	bloom += GetBloomPixel(tex, uv + off * vec2(1, 0), texPixelSize * bloomRadius) * 0.5;
	bloom += GetBloomPixel(tex, uv + off * vec2(1, 1), texPixelSize * bloomRadius) * 0.292893;
	bloom /= 4.171573f;
	return bloom;
}


// giwby-implementation
vec3 getbloom(sampler2D tex, vec2 uv, vec2 texelsize) {
	vec3 bloom = vec3(.0);
	vec4 tmp;
	for (float y = -bloomdetail; y < bloomdetail; y++) {
		for (float x = -bloomdetail; x < bloomdetail; x++) {
			tmp = texture(tex, uv + vec2(x,y) * texelsize / bloomRadius);
			bloom += tmp.rgb * max(0.0, length(tmp.rgb) - bloomThreshold);
		}
	}
	return bloom / (pow(bloomdetail*2, 2));
}

void main() {
    vec4 color;
    color = texture(colortex0, texcoord);

	#ifdef BLOOM
    vec3 bloom = getbloom(colortex0, texcoord, vec2(1./viewWidth, 1./viewHeight));

	color += vec4(bloom, 1.0) * ((hasSkylight) ? bloomIntensitySkyLightDimension : bloomIntensity);

	//color = vec4(bloom, 1.0);
	#endif

    gl_FragData[0] = color;
}
