#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform sampler2D u_image; // ./texture.png
out vec4 outputColor;

#define PI 3.14
#define uv gl_FragCoord.xy / u_resolution.xy
#define strength 3.0
#define angle 0.4

float noiseTexture(float deg) {
    float s = sin(deg), c = cos(deg);
    vec2 texSize = vec2(textureSize(u_image, 0));
    vec2 tex = uv * texSize;
    vec2 point = vec2(
        c * tex.x - s * tex.y,
        s * tex.x + c * tex.y
    ) * (PI / strength);
    return (sin(point.x) * sin(point.y)) * 4.0;
}

void main() {
    vec4 color = texture(u_image, uv);
    // 将颜色值转换到 CMY 颜色空间
    // 在 RGB 颜色空间中，亮度通常由三个颜色分量的平均值来表示，即 (R+G+B)/3
    // 在 CMY 颜色空间中，亮度通常由黑色分量（即 C、M 和 Y 中的最小值）来表示，这种方式下，颜色的处理可以更加独立，而不需要考虑亮度的影响
    vec3 cmy = 1.0 - color.rgb;
    // 获取 CMY 颜色空间中最小的颜色分量
    float k = min(cmy.x, min(cmy.y, cmy.z));
    // 将 CMY 颜色空间归一化
    cmy = (cmy - k) / (1.0 - k);
    // 对噪声进行缩放、偏移和剪裁
    cmy = clamp(cmy * 10.0 - 3.0 + vec3(noiseTexture(angle + 0.26179), noiseTexture(angle + 1.30899), noiseTexture(angle)), 0.0, 1.0);
    float val = clamp(k * 10.0 - 5.0 + noiseTexture(angle + 0.78539), 0.0, 1.0);
    // 转换回 RGB 颜色空间
    outputColor = vec4(1.0 - cmy - val, color.a);
}