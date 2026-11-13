#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);
	vec3 normals = (texture(colortex2, texcoord).xyz - 0.5) * 2.0;
	//color.rgb *= clamp(dot(normals, vec3(0.,1.,0.)), 0.5, 10.1);
	//color.rgb = normals;
}