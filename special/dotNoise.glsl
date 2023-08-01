#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform sampler2D u_image; // ./texture.png
out vec4 outputColor;

#define PI 3.14
#define uv gl_FragCoord.xy / u_resolution.xy
#define strength 3.0
#define angle 0.4

// 函数内部使用 sin 函数计算噪声值
float noiseTexture() {
    float s = sin(angle), c = cos(angle);
    vec2 texSize = vec2(textureSize(u_image, 0));
    vec2 tex = uv * texSize; // 将纹理坐标转换为像素坐标
    // 根据角度和强度计算噪声点的坐标
    vec2 point = vec2(
        c * tex.x - s * tex.y,
        s * tex.x + c * tex.y
    ) * (PI / strength);
    return (sin(point.x) * sin(point.y)) * 4.0;
}

void main() {
    vec4 color = texture(u_image, uv);
    // 颜色值转换为灰度值
    float average = (color.r + color.g + color.b) / 3.0;
    // 生成噪声纹理，并将其叠加到灰度值上
    float val = average * 10.0 - 5.0 + noiseTexture();
    outputColor = vec4(vec3(val), color.a);
}