shader_type canvas_item;

uniform float speed = 0.0001; // Very slow speed for subtle movement

void fragment() {
    vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE;

    // Shift the UV coordinates to center the gradient at the middle of the screen
    vec2 centered_uv = uv - vec2(0.5, 0.5);
    
    // Calculate the angle in radians and add time to create rotation
    float angle = atan(centered_uv.y, centered_uv.x) + TIME * speed;

    // Map the angle to a range of 0 to 6 for smooth transitions between six colors
    float t = mod(angle / (2.0 * 3.141592) * 6.0, 6.0);

    // Define the six pastel colors for the gradient
    vec3 color1 = vec3(0.8, 0.6, 0.6);  // Darker pink
    vec3 color2 = vec3(0.8, 0.8, 0.6);  // Darker yellow
    vec3 color3 = vec3(0.6, 0.8, 0.6);  // Darker green
    vec3 color4 = vec3(0.6, 0.8, 0.8);  // Darker cyan
    vec3 color5 = vec3(0.6, 0.6, 0.8);  // Darker lavender
    vec3 color6 = vec3(0.8, 0.6, 0.8);  // Darker purple

    // Transition smoothly between colors based on the calculated angle `t`
    vec3 color;
    if (t < 1.0) {
        color = mix(color1, color2, t);
    } else if (t < 2.0) {
        color = mix(color2, color3, t - 1.0);
    } else if (t < 3.0) {
        color = mix(color3, color4, t - 2.0);
    } else if (t < 4.0) {
        color = mix(color4, color5, t - 3.0);
    } else if (t < 5.0) {
        color = mix(color5, color6, t - 4.0);
    } else {
        color = mix(color6, color1, t - 5.0);
    }

    COLOR = vec4(color, 1.0);
}