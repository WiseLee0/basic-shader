#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform sampler2D u_image; // ./texture.png

out vec4 outputColor;

vec2 inflate(vec2 uv, vec2 center, float range, float strength) {
    float dist = distance(uv, center);
    vec2 dir = normalize(uv - center);
    float scale = 1.0 - strength + strength * smoothstep(0.0, 1.0, dist / range);
    dist = dist * scale;
    return center + dist * dir;
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    uv = inflate(uv, u_mouse / u_resolution, 0.3, 0.7);
    outputColor = texture(u_image, uv);
}