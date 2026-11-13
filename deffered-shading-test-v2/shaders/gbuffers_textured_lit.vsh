#version 330 compatibility

in vec4 at_tangent;

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
out vec4 position;
out vec3 tangent;
out vec3 bitangent;

void main() {
	const float inf = uintBitsToFloat(0x7f800000u);
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	vec3 normal_ = gl_Normal;
	position = gl_Position;

	// literally from the iris docs :skull:
	normal = gl_NormalMatrix * normal;
	tangent = gl_NormalMatrix * normalize(at_tangent.xyz);
	bitangent = cross(tangent, normal) * clamp(at_tangent.w * inf, -1.0, 1.0);

}