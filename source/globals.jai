PONG_VERSION :: "Version 0.4.0";
DEBUG_DRAW :: false;
DEBUG_DRAW_BOX2D :: false;

// Default to 1080p
WINDOW_WIDTH_INITIAL :: 1920;
WINDOW_HEIGHT_INITIAL :: 1080;
// WINDOW_WIDTH_INITIAL :: 1300;
// WINDOW_HEIGHT_INITIAL :: 1300;
// WINDOW_WIDTH_INITIAL :: #run cast(s32)(1.5*360);
// WINDOW_HEIGHT_INITIAL :: #run cast(s32)(1.5*800);
DT_MAX : float : 0.15;

BALL_INITIAL_RADIUS :: 0.4;
BALL_DENSITY :: 1.0;
BALL_FRICTION :: 0.0; // @Hack? We did the balls don't spin so that the predicted trajectory by shape-casting is accurate... maybe this doesn't matter though? I think it does since this is what the game is about...
BALL_RESTITUTION :: 1.0;
BALL_COUNT_MAX :: 4;
BALL_MAX_HEALTH :: 100.;
BALL_DAMAGE_SPEED :: #run 4. * BALL_INITIAL_SPEED;
BALL_INITIAL_SPEED :: #run 5. * PADDLE_EXTENTS.x / 1.; // 5 paddle lengths in 1 second
BALL_SPAWN_COUNTDOWN :: 2.;

LASER_THICKNESS :: 5.;
LASER_THICKNESS_CORE :: 2.;


Ai_Player :: struct {
    skill : Ai_Skill = .Mindless;
    direction : int = 1; // -1 => -x direction, 0 => stationary, 1 => +x direction
    direction_prev : int = 1;

    countdown : float = COUNTDOWN / 2.; // initialli
    COUNTDOWN : float : .3;
}
ai_player : Ai_Player;

player1_ball_spawn_countdown := 0.;
player2_ball_spawn_countdown := 0.;

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
LIVES_GRID_COLS :: 26;
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
player_count : Player_Count = .One_Player;
balls : [BALL_COUNT_MAX]Ball;


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

world_time_factor := 1.; // @TODOO remove this, and replce with individual player world factors
TIME_FACTOR_FAST :: 3.;
TIME_FACTOR_SLOW :: .1;

