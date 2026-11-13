#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D normals;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
in vec4 position;
in vec3 tangent;
in vec3 bitangent;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 otherdata;
layout(location = 2) out vec4 normalsOut;

void main() {
	const float inf = uintBitsToFloat(0x7f800000u);
	color = texture(gtexture, texcoord) * glcolor;
	//color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}
	vec3 normalMap = (texture(normals, texcoord).xyz - 0.5) * 2.0;

	//normalsOut = vec4((vec4(normalMap*gl_NormalMatrix, .0)*gl_ModelViewMatrix).xyz * 0.5 + 0.5, 1.0);
	//color = texture(normals, texcoord);

	

	normalsOut = vec4(normalize(tangent*normalMap.x + bitangent*normalMap.y + normal*normalMap.z), 1.0);
	color.rgb = normalize(tangent*normalMap.x + bitangent*normalMap.y + normal*normalMap.z)*0.5 + 0.5;
}