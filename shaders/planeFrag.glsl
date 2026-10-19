#version 460 core
layout(location = 0) out vec4 FragColor;

in vec2 FragPos;

uniform float uTime;

void main() {
    float param = sin(uTime * 2.0) * 0.5 + 0.5;
    vec3 color = mix(vec3(1.0, 1.0, 0.0), vec3(0.0, 0.5, 1.0), param);
    FragColor = vec4(color, param);
}
