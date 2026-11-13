/*
    Stems from XorDev's "Default Shaderpack"

    This was put together by @XorDev to make it easier for anyone to make their own shaderpacks in Minecraft (Optifine).
    You can do whatever you want with this code! Credit is not necessary, but always appreciated!

    You can find more information about shaders in Optfine here:
    https://github.com/sp614x/optifine/blob/master/OptiFineDoc/doc/shaders.txt

*/
//Declare GL version.
#version 120

#define HDR // internally support overbright tones

uniform int blockEntityId;

//Diffuse (color) texture.
uniform sampler2D texture;
//Lighting from day/night + shadows + light sources.
uniform sampler2D lightmap;

// camera pos
//uniform vec3 cameraPosition;

//RGB/intensity for hurt entities and flashing creepers.
uniform vec4 entityColor;
//0-1 amount of blindness.
uniform float blindness;
uniform float nightVision;
//0 = default, 1 = water, 2 = lava.
uniform int isEyeInWater;

//Vertex color.
varying vec4 color;
//Diffuse and lightmap texture coordinates.
varying vec2 coord0;
varying vec2 coord1;
//varying vec3 glpos;
varying vec2 vEntity;


const vec3 ign = vec3(0.06711056f, 0.00583715f, 52.9829189f);

vec2 sqrtuv(vec2 uv) {
    return vec2(sqrt(uv.x), sqrt(uv.y));
}

void main()
{
    //vec3 eyedir = normalize(glpos - cameraPosition).xyz;

    vec4 texsamp = texture(texture,coord0);
    vec3 lmsamp = texture(lightmap, coord1).rgb;

    vec3 light = vec3(0.5);

    switch (int(vEntity.x)) {
        case 2: // emissive
        case 7: // lava
            light = vec3(1.5);
            break;
        case 3: // partially-emissive
            light = mix(lmsamp, vec3(1.8), clamp(length(texsamp.rgb), 0.5, 1.6) - 0.6);
            break;
        default: // else
            light = mix((1.-blindness) * lmsamp, vec3(1.0), nightVision);
    }

    //Combine lightmap with blindness.
    //vec3 light = mix((1.-blindness) * texture(lightmap, coord1).rgb, vec3(1.0), (vEntity.x == 2) ? 1.0 : nightVision);
    //Sample texture times lighting.
    vec4 col = (color * vec4(light,1)) * texsamp;
    //Apply entity flashes.
    col.rgb = mix(col.rgb,entityColor.rgb,entityColor.a);

    //Calculate fog intensity in or out of water.
    float fog = (isEyeInWater>0) ? 1.-exp(-gl_FogFragCoord * gl_Fog.density):
        clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);

    //Apply the fog.
    col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);

    col.a = texsamp.a;


    // this chunk is stolen from @jacob on godotshaders.com, who just slightly changed a chunk of the core godot shading (https://godotshaders.com/shader/transparency-dither/)
    //if (col.a < 0.001 || col.a < fract(ign.z * fract(dot(gl_FragCoord.xy, ign.xy)))) {
	//	discard;
	//}

    //col.rgb = vec3(texture(texture,coord0).a); // to test if alpha exists, which it turns out it does

    #ifdef HDR
    col.rgb *= 0.8;
    #endif

    //Output the result.
    gl_FragData[0] = col;
}
