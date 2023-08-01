#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform sampler2D u_image; // ./texture.png
out vec4 outputColor;
uniform vec2 u_mouse;
#define PI 3.14
#define uv gl_FragCoord.xy / u_resolution.xy
#define brightness 0.1
#define radius 5.0
#define angle 0.0
uniform sampler2D u_buffer0;
uniform sampler2D u_buffer1;
uniform sampler2D u_buffer2;
uniform sampler2D u_buffer3;

// 随机化采样位置
float random(vec3 scale, float seed) {
    return fract(sin(dot(gl_FragCoord.xyz + seed, scale)) * 43758.5453 + seed);
}

vec4 getSample(sampler2D _texture, vec2 delta) {
    float offset = random(vec3(delta, 151.7182), 0.0);
    vec4 color = vec4(0.0);
    float total = 0.0;
    for(float t = 0.0; t <= 30.0; t ++ ) {
        float percent = (t + offset) / 30.0;
        color += texture(_texture, uv + delta * percent);
        total += 1.0;
    }
    return color / total;
}
vec2 getDelta(sampler2D _texture, float deg) {
    vec2 texSize = vec2(textureSize(_texture, 0));
    vec2 delta = vec2(radius * sin(deg), radius * cos(deg)) / texSize;
    return delta;
}

vec4 lensBlurPrePass(float power) {
    vec4 color = texture(u_image, uv);
    color = pow(color, vec4(power));
    return vec4(color);
}

vec4 lensBlur0(sampler2D _texture, float i) {
    float deg = angle + i * PI * 2.0 / 3.0;
    vec2 delta = getDelta(_texture, deg);
    return getSample(_texture, delta);
}
vec4 lensBlur1(sampler2D _texture) {
    float deg1 = angle + 1.0 * PI * 2.0 / 3.0;
    float deg2 = angle + 2.0 * PI * 2.0 / 3.0;
    vec2 delta1 = getDelta(_texture, deg1);
    vec2 delta2 = getDelta(_texture, deg2);
    return (getSample(_texture, delta1) + getSample(_texture, delta2)) * 0.5;
}
vec4 lensBlur2(sampler2D _texture) {
    float deg = angle + 2.0 * PI * 2.0 / 3.0;
    vec2 delta = getDelta(_texture, deg);
    return (getSample(_texture, delta) + 2.0 * texture(_texture, uv)) / 3.0;
}

#if defined(BUFFER_0)
// 重新映射纹理值，这将有助于制作散景效果
void main() {
    vec2 texSize = vec2(textureSize(u_image, 0));
    float power = pow(10.0, clamp(brightness, - 1.0, 1.0));
    outputColor = lensBlurPrePass(power);
}
#elif defined(BUFFER_1)
void main() {
    outputColor = lensBlur0(u_buffer0, 0.0);
}
#elif defined(BUFFER_2)
void main() {
    outputColor = lensBlur1(u_buffer1);
}
#elif defined(BUFFER_3)
void main() {
    outputColor = lensBlur0(u_buffer2, 1.0);
}
#else
void main() {
    outputColor = lensBlur2(u_buffer3);
}
#endif
