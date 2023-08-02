uniform vec2 u_resolution;
uniform vec2 u_image_resolution;
uniform float strength;
uniform float angle;
uniform shader u_image;

float PI = 3.14;

// 函数内部使用 sin 函数计算噪声值
float noiseTexture(vec2 uv) {
    float s = sin(angle), c = cos(angle);
    vec2 texSize = u_image_resolution.xy;
    vec2 tex = uv * texSize; // 将纹理坐标转换为像素坐标
    // 根据角度和强度计算噪声点的坐标
    vec2 point = vec2(
        c * tex.x - s * tex.y,
        s * tex.x + c * tex.y
    ) * (PI / strength);
    return (sin(point.x) * sin(point.y)) * 4.0;
}

vec4 main(vec2 fragCoord) {
    vec2 uv = fragCoord.xy / u_resolution.xy;
    vec4 color = u_image.eval(uv * u_image_resolution.xy);
    // 颜色值转换为灰度值
    float average = (color.r + color.g + color.b) / 3.0;
    // 生成噪声纹理，并将其叠加到灰度值上
    float val = average * 10.0 - 5.0 + noiseTexture(uv);
    return vec4(vec3(val), color.a);
}