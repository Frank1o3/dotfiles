#version 300 es
precision highp float;

in vec2 v_texcoord;
uniform sampler2D tex;
layout(location = 0) out vec4 fragColor;

void main() {
    vec4 color = texture(tex, v_texcoord);

    // Subtle warm glass tint - simulates light passing through fine optical glass
    color.r *= 1.015;
    color.g *= 1.008;
    color.b *= 0.985;

    // Subtle edge depth / vignette
    vec2 uv = v_texcoord * 2.0 - 1.0;
    float vignette = 1.0 - dot(uv * 0.22, uv * 0.22);
    color.rgb *= vignette;

    fragColor = color;
}
