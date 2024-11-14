shader_type canvas_item;

uniform float speed = 0.05; // Slow speed for subtle movement

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5, 0.5); // Center of the gradient in normalized UV space
    float distance = length(uv - center); // Distance from the center

    // Expanding effect with gradient from dark grey to slightly lighter grey
    float gradient_position = fract(distance - TIME * speed);

    // Define the two grey shades
    vec3 dark_grey = vec3(0.2);          // Dark grey
    vec3 slightly_lighter_grey = vec3(0.25); // Slightly lighter than dark grey

    // Smoothly transition between dark grey and slightly lighter grey
    vec3 color = mix(dark_grey, slightly_lighter_grey, gradient_position);

    COLOR = vec4(color, 1.0);
}
