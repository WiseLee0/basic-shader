#version 300 es
precision mediump float;

uniform vec2 u_resolution;
uniform sampler2D u_image; // ./texture.png
out vec4 outputColor;
#define strength 1.0

// Sobel operator
const mat3 sobelX = mat3(
    - 1.0, 0.0, 1.0,
    - 2.0, 0.0, 2.0,
    - 1.0, 0.0, 1.0
);
const mat3 sobelY = mat3(
    - 1.0, - 2.0, - 1.0,
    0.0, 0.0, 0.0,
    1.0, 2.0, 1.0
);

// Laplacian operator
const mat3 laplacian = mat3(
    0.0, - 1.0, 0.0,
    - 1.0, 4.0, - 1.0,
    0.0, - 1.0, 0.0
);

vec4 drawEffect() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    vec2 pixelSize = strength * vec2(1.0) / vec2(textureSize(u_image, 0));
    vec3 color = texture(u_image, uv).rgb;
    vec3 gx = vec3(0);
    vec3 gy = vec3(0);
    for(int i = -1; i <= 1; i ++ ) {
        for(int j = -1; j <= 1; j ++ ) {
            vec3 _sample = texture(u_image, uv + vec2(i, j) * pixelSize).rgb;
            // Sobel算子或者拉普拉斯算子
            // 两种算子都对图像噪声比较敏感，可使用高斯模糊等方法来消除图像噪声
            gx += _sample * sobelX[i + 1][j + 1];
            gy += _sample * sobelY[i + 1][j + 1];
            // gx += _sample * laplacian[i + 1][j + 1];
            // gy += _sample * laplacian[i + 1][j + 1];
        }
    }
    float c = clamp(length(gx) + length(gy), 0.0, 1.0);
    return vec4(vec3(c), 1.0);
}

void main() {
    outputColor = drawEffect();
}