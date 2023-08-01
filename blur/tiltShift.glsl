#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform sampler2D u_image; // ./texture.png
out vec4 outputColor;
uniform vec2 u_mouse;

#define uv gl_FragCoord.xy / u_resolution.xy
#define blurRadius 30.0
#define gradientRadius 200.0
#define startX 0.1
#define startY 0.5
#define endX 0.5
#define endY 0.5

uniform sampler2D u_buffer0;

// 随机化采样位置
float random(vec3 scale, float seed) {
    return fract(sin(dot(gl_FragCoord.xyz + seed, scale)) * 43758.5453 + seed);
}
#if defined(BUFFER_0)
// 沿着起点到终点的线性梯度进行模糊，距离线性梯度越近的像素被模糊程度越高
void main() {
    vec2 texSize = vec2(textureSize(u_image, 0));
    
    float dx = (endX - startX) * texSize.x;
    float dy = (endY - startY) * texSize.y;
    vec2 start = vec2(startX, startY) * texSize;
    vec2 end = vec2(endX, endY) * texSize;
    float d = sqrt(dx * dx + dy * dy);
    vec2 delta = vec2(dx / d, dy / d);
    
    vec4 color = vec4(0.0);
    float total = 0.0;
    float offset = random(vec3(12.9898, 78.233, 151.7182), 0.0);
    // 计算当前像素到线的距离，并将距离转换为模糊半径
    vec2 normal = normalize(vec2(start.y - end.y, end.x - start.x));
    float radius = smoothstep(0.0, 1.0, abs(dot(uv * texSize - start, normal)) / gradientRadius) * blurRadius;
    
    for(float t = -30.0; t <= 30.0; t ++ ) {
        float percent = (t + offset - 0.5) / 30.0;
        float weight = 1.0 - abs(percent);
        vec4 _sample = texture(u_image, uv + delta / texSize * percent * radius);
        _sample.rgb *= _sample.a;
        color += _sample * weight;
        total += weight;
    }
    outputColor = color / total;
    outputColor.rgb /= outputColor.a + 0.00001;
}
#else
void main() {
    vec2 texSize = vec2(textureSize(u_buffer0, 0));
    
    float dx = (endX - startX) * texSize.x;
    float dy = (endY - startY) * texSize.y;
    vec2 start = vec2(startX, startY) * texSize;
    vec2 end = vec2(endX, endY) * texSize;
    float d = sqrt(dx * dx + dy * dy);
    vec2 delta = vec2(-dy / d, dx / d);
    
    vec4 color = vec4(0.0);
    float total = 0.0;
    float offset = random(vec3(12.9898, 78.233, 151.7182), 0.0);
    // 计算当前像素到线的距离，并将距离转换为模糊半径
    vec2 normal = normalize(vec2(start.y - end.y, end.x - start.x));
    float radius = smoothstep(0.0, 1.0, abs(dot(uv * texSize - start, normal)) / gradientRadius) * blurRadius;
    
    for(float t = -30.0; t <= 30.0; t ++ ) {
        float percent = (t + offset - 0.5) / 30.0;
        float weight = 1.0 - abs(percent);
        vec4 _sample = texture(u_buffer0, uv + delta / texSize * percent * radius);
        _sample.rgb *= _sample.a;
        color += _sample * weight;
        total += weight;
    }
    outputColor = color / total;
    outputColor.rgb /= outputColor.a + 0.00001;
}
#endif