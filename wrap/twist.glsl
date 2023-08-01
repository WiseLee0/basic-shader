#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform sampler2D u_image; // ./texture.png

out vec4 outputColor;
#define PI 3.14

// 旋转矩阵
mat2 rotate(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, - s, s, c);
}
vec2 deform(vec2 uv, vec2 center, float range, float angle) {
    float dist = distance(uv, center);
    uv -= center; // center 成为坐标系的原点
    dist = smoothstep(0.0, range, range - dist);
    uv *= rotate(dist * angle);
    uv += center; // 还原坐标系的原点
    return uv;
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    uv = deform(uv, u_mouse / u_resolution, 0.2, PI);
    outputColor = texture(u_image, uv);
}