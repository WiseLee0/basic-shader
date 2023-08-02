uniform vec2 u_resolution;
uniform vec2 u_image_resolution;
uniform float u_strength;
uniform float u_render;
uniform shader u_image;

// 随机化采样位置
float random(vec2 fragCoord, vec3 scale, float seed) {
    return fract(sin(dot(vec3(fragCoord.xy, 1.0) + seed, scale)) * 43758.5453 + seed);
}

// 水平和垂直方向各一次模糊
vec4 main(vec2 fragCoord) {
    vec2 uv = fragCoord.xy / u_resolution.xy;
    vec2 texSize = u_resolution.xy;
    vec2 delta;
    if (u_render == 0.0) {
        // 横向模糊
        delta = vec2(u_strength / texSize.x, 0);
    }else {
        // 纵向模糊
        delta = vec2(0, u_strength / texSize.y);
    }
    vec4 color = vec4(0.0);
    float total = 0.0;
    float offset = random(fragCoord, vec3(12.9898, 78.233, 151.7182), 0.0);
    for(float t = -30.0; t <= 30.0; t ++ ) {
        float percent = (t + offset - 0.5) / 30.0;
        float weight = 1.0 - abs(percent);
        vec4 _sample = u_image.eval((uv + delta * percent) * u_image_resolution.xy);
        _sample.rgb *= _sample.a;
        color += _sample * weight;
        total += weight;
    }
    color = color / total;
    color.rgb /= color.a + 0.00001;
    return color;
}

