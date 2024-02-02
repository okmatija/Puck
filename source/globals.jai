PONG_VERSION :: "Version 0.3.1";
DEBUGGING :: false;

// Default to 1080p
WINDOW_WIDTH_INITIAL :: 1920;
WINDOW_HEIGHT_INITIAL :: 1080;
// WINDOW_WIDTH_INITIAL :: 1300;
// WINDOW_HEIGHT_INITIAL :: 1300;
// WINDOW_WIDTH_INITIAL :: #run cast(s32)(1.5*360);
// WINDOW_HEIGHT_INITIAL :: #run cast(s32)(1.5*800);
DT_MAX : float : 0.15;

BALL_RADIUS_INITIAL :: 0.4;
BALL_DENSITY :: 1.0;
BALL_FRICTION :: 1.0;
BALL_RESTITUTION :: 1.0;
BALL_COUNT_MAX :: 4;
BALL_DAMAGE_SPEED :: #run 6. * length(initial_ball_velocity());
BALL_MAX_HEALTH :: 100.;

BOUNDARY_THICKNESS_PX :: 3;

Explosion :: struct {
    EXPLOSION_DURATION :: .5; // Seconds
    countdown := EXPLOSION_DURATION;

    position : Vector2;
    radius : float;
    color : Vector4;
}
ball_explosions : [..]Explosion;

WALL_FRICTION :: 0.0; // Set to zero because otherwise we get into situations where the ball bounces back and forth horizontally... also it seems better to have the spin only affected by player movement
WALL_RESTITUTION :: 0.0;

// The paddle extents is the main scaling entity!
PADDLE_EXTENTS :: Vector2.{2.0, 0.25};
PADDLE_SPEED :: #run (5.0 * PADDLE_EXTENTS.x / 0.35); // move 5 paddle widths in 0.35 seconds
PADDLE_DENSITY :: 1000;
PADDLE_FRICTION :: 1.;
PADDLE_RESTITUTION :: 1.2;

PLAYER_MAX_LIVES :: #run LIVES_GRID_ROWS * LIVES_GRID_COLS;
LIVES_GRID_COLS :: 13;
LIVES_GRID_ROWS :: 3;
LIVES_GRID_SPACING :: .1;
LIFE_MAX_HEALTH :: 100.;

DEFAULT_PORT : u16 : 42069;

// player_name: string; // @Cleanup move to Player struct
// server_address: string;
host_info : Host_Info;

server_address : string;
server_port : u16 = DEFAULT_PORT;
server_port_string : string;

window : Window_Type;
window_height : s32;
window_width  : s32;

font : *Simp.Dynamic_Font;
version_font : *Simp.Dynamic_Font;
game_over_font : *Simp.Dynamic_Font;

game_quitting : bool;
game_menu : Game_Menu;
game_mode : Game_Mode;
game_over_text : string;


current_frame : u64;
current_dt: float = 1. / 60.; // Seconds
current_time: float64; // Seconds
last_time:  float64; // Seconds

level : Level;
player1 : Player;
player2 : Player;
player_count : Player_Count = .Two_Player;
balls : [BALL_COUNT_MAX]Ball;

ball_spawn_countdown := 0.;
BALL_SPAWN_COUNTDOWN :: 2.;

world : *b2World;
contact_listener : b2ContactListener;
world_debug_draw : *b2Draw;

host_type : Host_Type = .UNKNOWN;
server : Server;
client : Client;
network_events_this_frame : [..]Enet.Event;

// Important these are global and persist across frames to preserve previous key down state
input1 : Client_Input;
input2 : Client_Input;
esc_pressed : bool;

data_folder: string;
sky_map : Texture;
menu_map : Texture;
okpong_map : Texture;
heart_map : Texture;
power_up_restore_all_life : Texture;
sound_start_game : Sound.Sound_Data;
sound_collision1 : Sound.Sound_Data;
sound_collision2 : Sound.Sound_Data;
sound_ball_explode : Sound.Sound_Data;

previous_mouse_x : s32;
previous_mouse_y : s32;
draw_mouse_in_game_countdown : float = DRAW_MOUSE_IN_GAME_COUNTDOWN;
DRAW_MOUSE_IN_GAME_COUNTDOWN :: .5;

user_sfx_volume : float = .1;

time_factor := 1.;
TIME_FACTOR :: .3;
WARP_SPEEDUP :: #run 1. / TIME_FACTOR;
WARP_COUNTDOWN :: .4;;