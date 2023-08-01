#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform sampler2D u_image; // ./texture.png
out vec4 outputColor;

#define PI 3.14
#define strength 60.0

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 texSize = vec2(textureSize(u_image, 0));
    vec2 tex = (uv * texSize) / strength;
    tex.x = floor(tex.x);
    tex.y = floor(tex.y);
    tex *= (strength / texSize);
    outputColor = texture(u_image, tex);
}