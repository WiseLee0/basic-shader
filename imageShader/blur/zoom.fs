uniform vec2 u_resolution;
uniform vec2 u_image_resolution;
uniform vec2 u_point;
uniform float u_strength;
uniform shader u_image;

// 随机化采样位置
float random(vec2 fragCoord, vec3 scale, float seed) {
    return fract(sin(dot(vec3(fragCoord.xy, 1.0) + seed, scale)) * 43758.5453 + seed);
}

vec4 main(vec2 fragCoord) {
    vec2 scale = u_image_resolution.xy / u_resolution.xy;
    vec2 uv = fragCoord.xy / u_resolution.xy;
    vec4 color = vec4(0.0);
    float total = 0.0;
    vec2 center = u_point;
    vec2 texSize = u_image_resolution;
    center = texSize * center;
    // 计算当前像素到中心点的距离向量
    vec2 toCenter = center - uv * texSize;
    float offset = random(fragCoord, vec3(12.9898, 78.233, 151.7182), 0.0);
    // 采样40个样本
    for(float t = 0.0; t <= 40.0; t ++ ) {
        // 计算当前采样位置的比例
        float percent = (t + offset) / 40.0;
        // 计算当前采样位置的权重，使用了一个权重函数
        float weight = 4.0 * (percent - percent * percent);
        // 采样当前位置的像素颜色
        vec4 _sample = u_image.eval((uv + toCenter * percent * u_strength / texSize) * u_image_resolution.xy);
        // 颜色值乘以透明度，使用预乘法处理透明度，以正确模糊半透明图像
        _sample.rgb *= _sample.a;
        // 将当前采样位置的颜色乘以权重并加入到总颜色中
        color += _sample * weight;
        // 累加权重
        total += weight;
    }
    // 计算最终颜色，即所有采样位置的颜色加权平均
    color = color / total;
    // 将颜色值除以透明度，使颜色值恢复原始值
    color.rgb /= color.a + 0.00001;
    
    return color;
}