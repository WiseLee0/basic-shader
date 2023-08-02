uniform vec2 u_resolution;
uniform vec2 u_image_resolution;
uniform float brightness;
uniform float radius;
uniform float angle;
uniform float u_render;
uniform shader u_image;
vec2 gfragCoord;
float PI = 3.14;
// 随机化采样位置
float random(vec2 fragCoord, vec3 scale, float seed) {
    return fract(sin(dot(vec3(fragCoord.xy, 1.0) + seed, scale)) * 43758.5453 + seed);
}

vec4 getSample(vec2 uv, vec2 delta) {
    float offset = random(gfragCoord, vec3(delta, 151.7182), 0.0);
    vec4 color = vec4(0.0);
    float total = 0.0;
    for(float t = 0.0; t <= 30.0; t ++ ) {
        float percent = (t + offset) / 30.0;
        color += u_image.eval((uv + delta * percent) * u_image_resolution.xy);
        total += 1.0;
    }
    return color / total;
}
vec2 getDelta(float deg) {
    vec2 texSize = u_image_resolution.xy;
    vec2 delta = vec2(radius * sin(deg), radius * cos(deg)) / texSize;
    return delta;
}

vec4 lensBlurPrePass(vec2 uv, float power) {
    vec4 color = u_image.eval(uv * u_image_resolution.xy);
    color = pow(color, vec4(power));
    return vec4(color);
}

vec4 lensBlur0(vec2 uv, float i) {
    float deg = angle + i * PI * 2.0 / 3.0;
    vec2 delta = getDelta(deg);
    return getSample(uv, delta);
}
vec4 lensBlur1(vec2 uv) {
    float deg1 = angle + 1.0 * PI * 2.0 / 3.0;
    float deg2 = angle + 2.0 * PI * 2.0 / 3.0;
    vec2 delta1 = getDelta(deg1);
    vec2 delta2 = getDelta(deg2);
    return (getSample(uv, delta1) + getSample(uv, delta2)) * 0.5;
}
vec4 lensBlur2(vec2 uv) {
    float deg = angle + 2.0 * PI * 2.0 / 3.0;
    vec2 delta = getDelta(deg);
    return (getSample(uv, delta) + 2.0 * u_image.eval(uv * u_image_resolution.xy)) / 3.0;
}

// 重新映射纹理值，这将有助于制作散景效果
vec4 main(vec2 fragCoord) {
    gfragCoord = fragCoord;
    vec2 uv = fragCoord.xy / u_resolution.xy;
    if (u_render == 0.0) {
        vec2 texSize = u_image_resolution.xy;
        float power = pow(10.0, clamp(brightness, - 1.0, 1.0));
        return lensBlurPrePass(uv, power);
    }
    if (u_render == 1.0) {
        return lensBlur0(uv, 0.0);
    }
    if (u_render == 2.0) {
        return lensBlur1(uv);
    }
    if (u_render == 3.0) {
        return lensBlur0(uv, 1.0);
    }
    if (u_render == 4.0) {
        return lensBlur2(uv);
    }
    return vec4(0.0, 0.0, 0.0, 1.0);
}

