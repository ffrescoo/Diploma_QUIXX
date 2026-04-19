#version 460 core
#include <flutter/runtime_effect.glsl>

uniform float uTime;
uniform vec2 uSize;

out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uSize.xy;

    uv *= 3.5;

    float len;
    for(int i = 0; i < 3; i++) {
        len = length(uv);
        uv.x += sin(uv.y + uTime * 0.08) * 5.0;
        uv.y += cos(uv.x + uTime * 0.05 + cos(len * 2.0)) * 2.0;
    }

    vec3 col = vec3(cos(len + 0.3), cos(len + 0.1), cos(len - 0.1));

    fragColor = vec4(col, 1.0);
}