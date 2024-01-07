precision highp float;

uniform sampler2D u_particles;

uniform sampler2D u_wind1;
uniform sampler2D u_wind2;
uniform float u_phase;

uniform vec2 u_wind_res1;
uniform vec2 u_wind_min1;
uniform vec2 u_wind_max1;

uniform vec2 u_wind_res2;

uniform vec2 u_wind_min2;
uniform vec2 u_wind_max2;




uniform float u_rand_seed;
uniform float u_speed_factor;
uniform float u_drop_rate;
uniform float u_drop_rate_bump;

varying vec2 v_tex_pos;

// pseudo-random generator
const vec3 rand_constants = vec3(12.9898, 78.233, 4375.85453);
float rand(const vec2 co) {
    float t = dot(rand_constants.xy, co);
    return fract(sin(t) * (rand_constants.z + t));
}

// wind speed lookup; use manual bilinear filtering based on 4 adjacent pixels for smooth interpolation
vec2 lookup_wind(const sampler2D texture, const vec2 text_res ,const vec2 uv) {
    // return texture2D(texture, uv).rg; // lower-res hardware filtering
    vec2 px = 1.0 / text_res;
    vec2 vc = (floor(uv * text_res)) * px;
    vec2 f = fract(uv * text_res);
    vec2 tl = texture2D(texture, vc).rg;
    vec2 tr = texture2D(texture, vc + vec2(px.x, 0)).rg;
    vec2 bl = texture2D(texture, vc + vec2(0, px.y)).rg;
    vec2 br = texture2D(texture, vc + px).rg;
    return mix(mix(tl, tr, f.x), mix(bl, br, f.x), f.y);
}

void main() {
    vec4 color = texture2D(u_particles, v_tex_pos);
    vec2 pos = vec2(
        color.r / 255.0 + color.b,
        color.g / 255.0 + color.a); // decode particle position from pixel RGBA

    vec2 velocity1 = mix(u_wind_min1, u_wind_max1, lookup_wind(u_wind1, u_wind_res1,pos));
    vec2 velocity2 = mix(u_wind_min2, u_wind_max2, lookup_wind(u_wind2, u_wind_res2, pos));

    float speed_t1 = length(velocity1) / length(u_wind_max1);
    float speed_t2 = length(velocity2) / length(u_wind_max2);
    float speed_t = mix(speed_t1, speed_t2, u_phase);

    vec2 velocity = mix( velocity1, velocity2, u_phase)

    // take EPSG:4236 distortion into account for calculating where the particle moved



    float distortion = cos(radians(pos.y * 180.0 - 90.0));
    vec2 offset = vec2(velocity.x / distortion, -velocity.y) * 0.0001 * u_speed_factor;

    // update particle position, wrapping around the date line
    pos = fract(1.0 + pos + offset);

    // a random seed to use for the particle drop
    vec2 seed = (pos + v_tex_pos) * u_rand_seed;

    // drop rate is a chance a particle will restart at random position, to avoid degeneration
    float drop_rate = u_drop_rate + speed_t * u_drop_rate_bump;
    float drop = step(1.0 - drop_rate, rand(seed));

    vec2 random_pos = vec2(
        rand(seed + 1.3),
        rand(seed + 2.1));
    pos = mix(pos, random_pos, drop);

    // encode the new particle position back into RGBA
    gl_FragColor = vec4(
        fract(pos * 255.0),
        floor(pos * 255.0) / 255.0);
}
