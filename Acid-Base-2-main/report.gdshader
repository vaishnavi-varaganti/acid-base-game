shader_type canvas_item;

uniform vec3 color1 = vec3(0.6, 0.4, 0.4);  // Darker pink
uniform vec3 color2 = vec3(0.6, 0.6, 0.4);  // Darker yellow
uniform vec3 color3 = vec3(0.4, 0.6, 0.4);  // Darker green
uniform vec3 color4 = vec3(0.4, 0.6, 0.6);  // Darker cyan
uniform vec3 color5 = vec3(0.4, 0.4, 0.6);  // Darker lavender
uniform vec3 color6 = vec3(0.6, 0.4, 0.6);  // Darker purple

uniform float scale = 10.0;     // Scale for more distance between dots

uniform float dot_size = 0.05;  // Reduced size of confetti dots

uniform float speed = 0.2;      // Speed of the falling effect

// Random function for generating random values
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV * scale;

    // Create a randomized falling effect by shifting UV.y based on time and random offset per cell
    uv.y += fract(TIME * speed + random(uv) * 5.0); // Randomized offset per cell

    vec2 grid = floor(uv); // Get the grid position

    vec2 random_offset = vec2(random(grid), random(grid + 1.0)) * 0.5 - 0.25; // Random offset within cell

    vec2 pos = fract(uv) + random_offset;  // Add random offset to position within each cell
    
    // Select a random color for each confetti piece
    vec3 color;
    float rnd = random(grid);
    if (rnd < 0.17) {
        color = color1;
    } else if (rnd < 0.33) {
        color = color2;
    } else if (rnd < 0.5) {
        color = color3;
    } else if (rnd < 0.67) {
        color = color4;
    } else if (rnd < 0.83) {
        color = color5;
    } else {
        color = color6;
    }

    // Slow, random blinking effect based on time and position
    float blink_speed = 0.1;  // Controls the speed of the blinking effect

    float blink_random = random(grid * 0.3) * 2.0;  // Additional randomness for each dot

    float blink = step(0.5, fract(sin(dot(grid, vec2(12.9898, 78.233)) + TIME * blink_speed + blink_random) * 43758.5453123));

    // Draw circles (confetti dots) within the grid with random offset
    float dist = length(pos - vec2(0.5));  // Distance from the center
    if (dist < dot_size && blink > 0.0) {
        COLOR = vec4(color, 1.0); // Confetti dot color with blinking effect
    } else {
        COLOR = vec4(vec3(0.1), 1.0); // Background color (dark grey)
    }

}