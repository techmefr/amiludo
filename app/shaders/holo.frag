#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec2 uTilt;
uniform float uStrength;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float angle = dot(uv - uTilt, vec2(0.8, 0.6));
  vec3 rainbow = 0.5 + 0.5 * cos(6.28318 * (angle * 2.0 + vec3(0.0, 0.33, 0.67)));
  float band = smoothstep(0.0, 0.5, 0.5 - abs(fract(angle * 3.0) - 0.5));
  float glint = exp(-8.0 * length(uv - uTilt));
  float a = uStrength * (0.18 + 0.32 * band + 0.4 * glint);
  fragColor = vec4(rainbow * a, a);
}
