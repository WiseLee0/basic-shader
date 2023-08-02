uniform vec2 u_resolution;
uniform vec2 u_image_resolution;
uniform float blurRadius;
uniform float gradientRadius;
uniform float2 startPoint;
uniform float2 endPoint;
uniform float u_render;
uniform shader u_image;

// 随机化采样位置
float random(vec2 fragCoord, vec3 scale, float seed) {
    return fract(sin(dot(vec3(fragCoord.xy, 1.0) + seed, scale)) * 43758.5453 + seed);
}

// 沿着起点到终点的线性梯度进行模糊，距离线性梯度越近的像素被模糊程度越高
vec4 main(vec2 fragCoord) {
    vec2 uv = fragCoord.xy / u_resolution.xy;
    vec2 texSize = u_resolution.xy;
    float startX = startPoint[0];
    float startY = startPoint[1];
    float endX = endPoint[0];
    float endY = endPoint[1];
    float dx;
    float dy;
    vec2 start;
    vec2 end;
    float d;
    vec2 delta;
    
    if (u_render == 0.0) {
        dx = (endX - startX) * texSize.x;
        dy = (endY - startY) * texSize.y;
        start = vec2(startX, startY) * texSize;
        end = vec2(endX, endY) * texSize;
        d = sqrt(dx * dx + dy * dy);
        delta = vec2(dx / d, dy / d);
    }else {
        dx = (endX - startX) * texSize.x;
        dy = (endY - startY) * texSize.y;
        start = vec2(startX, startY) * texSize;
        end = vec2(endX, endY) * texSize;
        d = sqrt(dx * dx + dy * dy);
        delta = vec2(-dy / d, dx / d);
    }
    
    vec4 color = vec4(0.0);
    float total = 0.0;
    float offset = random(fragCoord, vec3(12.9898, 78.233, 151.7182), 0.0);
    // 计算当前像素到线的距离，并将距离转换为模糊半径
    vec2 normal = normalize(vec2(start.y - end.y, end.x - start.x));
    float radius = smoothstep(0.0, 1.0, abs(dot(uv * texSize - start, normal)) / gradientRadius) * blurRadius;
    
    for(float t = -30.0; t <= 30.0; t ++ ) {
        float percent = (t + offset - 0.5) / 30.0;
        float weight = 1.0 - abs(percent);
        vec4 _sample = u_image.eval((uv + delta / texSize * percent * radius) * u_image_resolution.xy);
        _sample.rgb *= _sample.a;
        color += _sample * weight;
        total += weight;
    }
    color = color / total;
    color.rgb /= color.a + 0.00001;
    return color;
}
