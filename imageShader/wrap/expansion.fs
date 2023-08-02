uniform vec2 u_resolution;
uniform vec2 u_image_resolution;
uniform vec2 u_point;
uniform float u_range;
uniform float u_strength;
uniform shader u_image;

vec2 inflate(vec2 uv, vec2 center, float range, float strength) {
    float dist = distance(uv, center);
    vec2 dir = normalize(uv - center);
    float scale = 1.0 - strength + strength * smoothstep(0.0, 1.0, dist / range);
    dist = dist * scale;
    return center + dist * dir;
}

vec4 main(vec2 fragCoord) {
    vec2 scale = u_image_resolution.xy / u_resolution.xy;
    vec2 uv = fragCoord.xy / u_resolution.xy;
    uv = inflate(uv, u_point, u_range, u_strength);
    // 设置越界的颜色值为透明
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return vec4(0.0, 0.0, 0.0, 0.0);
    }
    return u_image.eval(uv * u_image_resolution.xy);
}