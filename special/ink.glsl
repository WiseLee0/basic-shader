#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform sampler2D u_image; // ./texture.png
out vec4 outputColor;

#define strength 1.0

vec4 ink() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 texSize = vec2(textureSize(u_image, 0));
    vec2 dx = vec2(1.0 / texSize.x, 0.0);
    vec2 dy = vec2(0.0, 1.0 / texSize.y);
    float bigTotal = 0.0;
    float smallTotal = 0.0;
    vec3 bigAverage = vec3(0.0);
    vec3 smallAverage = vec3(0.0);
    // 遍历周围的像素点，计算大范围和小范围内的像素颜色平均值和总数
    for(float x = -2.0; x <= 2.0; x += 1.0) {
        for(float y = -2.0; y <= 2.0; y += 1.0) {
            vec3 _sample = texture(u_image, uv + dx * x + dy * y).rgb;
            bigAverage += _sample;
            bigTotal += 1.0;
            if (abs(x) + abs(y) < 2.0) {
                smallAverage += _sample;
                smallTotal += 1.0;
            }
        }
    }
    // 计算像素的边缘值
    vec3 edge = max(vec3(0.0), bigAverage / bigTotal - smallAverage / smallTotal);
    vec4 color = texture(u_image, uv);
    // 使用像素的边缘值减弱该像素的颜色强度
    return vec4(color.rgb - dot(edge, edge) * pow(strength, 5.0) * 100000.0, color.a);
}

void main() {
    outputColor = ink();
}