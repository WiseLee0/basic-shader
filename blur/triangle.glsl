#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform sampler2D u_image; // ./texture.png
out vec4 outputColor;
uniform vec2 u_mouse;

#define uv gl_FragCoord.xy / u_resolution.xy
#define strength 30.0

uniform sampler2D u_buffer0;

// 随机化采样位置
float random(vec3 scale, float seed) {
    return fract(sin(dot(gl_FragCoord.xyz + seed, scale)) * 43758.5453 + seed);
}

// 水平和垂直方向各一次模糊
#if defined(BUFFER_0)
void main() {
    vec2 texSize = vec2(textureSize(u_image, 0));
    // 横向模糊
    vec2 delta = vec2(strength / texSize.x, 0);
    // 纵向模糊
    // vec2 delta = vec2(0, strength / texSize.y);
    vec4 color = vec4(0.0);
    float total = 0.0;
    float offset = random(vec3(12.9898, 78.233, 151.7182), 0.0);
    for(float t = -30.0; t <= 30.0; t ++ ) {
        float percent = (t + offset - 0.5) / 30.0;
        float weight = 1.0 - abs(percent);
        vec4 _sample = texture(u_image, uv + delta * percent);
        _sample.rgb *= _sample.a;
        color += _sample * weight;
        total += weight;
    }
    outputColor = color / total;
    outputColor.rgb /= outputColor.a + 0.00001;
}
#else
void main() {
    vec2 texSize = vec2(textureSize(u_buffer0, 0));
    // 横向模糊
    // vec2 delta = vec2(strength / texSize.x, 0);
    // 纵向模糊
    vec2 delta = vec2(0, strength / texSize.y);
    vec4 color = vec4(0.0);
    float total = 0.0;
    float offset = random(vec3(12.9898, 78.233, 151.7182), 0.0);
    for(float t = -30.0; t <= 30.0; t ++ ) {
        float percent = (t + offset - 0.5) / 30.0;
        float weight = 1.0 - abs(percent);
        vec4 _sample = texture(u_buffer0, uv + delta * percent);
        _sample.rgb *= _sample.a;
        color += _sample * weight;
        total += weight;
    }
    outputColor = color / total;
    outputColor.rgb /= outputColor.a + 0.00001;
}
#endif
