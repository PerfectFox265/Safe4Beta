shader_type canvas_item;

uniform sampler2D fs_text_texture : repeat_enable, filter_nearest;
uniform sampler2D noise_texture : repeat_enable, filter_nearest;

uniform float shake_power = 0.03;
uniform float shake_rate : hint_range( 0.0, 1.0 ) = 0.2;
uniform float shake_speed = 5.0;
uniform float shake_block_size = 30.5;
uniform float shake_color_rate : hint_range( 0.0, 1.0 ) = 0.01;
//uniform float transparent_square_rate : hint_range( 0.0, 1.0 ) = 0.5;

float random( float seed )
{
	return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46, -54.3415 ) ) ) );
}

void fragment( )
{
	float enable_shift = 1.0;
	// for deactivating the filter randomly (make the "old frame copy" very visible)
	float mtime = mod(TIME,100.0);
	enable_shift = float(random( trunc(mtime * shake_speed )) < shake_rate);

	vec2 fixed_uv = SCREEN_UV + vec2(0., 0.07*mtime);
	fixed_uv.x += (
		random(( trunc( (SCREEN_UV.y - mtime) * shake_block_size ) / shake_block_size ) +	mtime ) - 0.5
	) * shake_power * enable_shift;
	fixed_uv.y += (
		random(( trunc( (SCREEN_UV.x - mtime) * shake_block_size ) / shake_block_size ) +	mtime ) - 0.5
	) * shake_power / 1.5 * enable_shift;

	vec4 pixel_color = textureLod( fs_text_texture, fixed_uv, 0.0 );
	pixel_color.r = mix(
		pixel_color.r
	,	textureLod( fs_text_texture, fixed_uv + vec2( shake_color_rate, 0.0 ), 0.0 ).r
	,	enable_shift
	);
	pixel_color.b = mix(
		pixel_color.b
	,	textureLod(fs_text_texture, fixed_uv + vec2( -shake_color_rate, 0.0 ), 0.0 ).b
	,	enable_shift
	);
	COLOR = pixel_color;
	float margin = 0.45;
	float margin_y_size = 0.5;
	float margin_speed = 3.0;
	float seed_from_y = UV.y/margin_y_size + margin_speed*mtime;
	float hmargin_from_y = margin*texture(noise_texture, vec2(seed_from_y, 0.3)).x;
	float tr2 = 2.0*hmargin_from_y*hmargin_from_y;
	float invisible_margin = float(UV.x > tr2 && UV.x < 1.0-tr2);
	COLOR.w = invisible_margin * pow(texture(TEXTURE, UV).x, 0.8);
}

