uniform vec2 u_resolution;
uniform vec2 u_image_resolution;
uniform vec2 u_point;
uniform float u_range;
uniform float u_strength;
uniform shader u_image;

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

vec4 main(vec2 fragCoord) {
    vec2 scale = u_image_resolution.xy / u_resolution.xy;
    vec2 uv = fragCoord.xy / u_resolution.xy;
    uv = deform(uv, u_point, u_range, u_strength);
    // 设置越界的颜色值为透明
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return vec4(0.0, 0.0, 0.0, 0.0);
    }
    return u_image.eval(uv * u_image_resolution.xy);
}