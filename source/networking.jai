Server :: struct {
    using host : *Enet.Host;

    // Data used to init the game, filled in with data from clients and only then
    // broadcast to all clients.  Clients start their games, when they recieve
    // this data
    init_game_state : Init_Game_State;
    init_game_state_ready : bool;
}

Client :: struct {
    using host : *Enet.Host;
    server : *Enet.Peer; // @Cleanup Rather that storing this, can we access client.host.peers?
}

Host_Type :: enum {
    UNKNOWN;
    LOCAL;
    CLIENT;
    SERVER;
}

Host_Info :: struct {
    hostname : string;
    ipv4 : u32;
    port : u16 = DEFAULT_PORT; // This is configurable
}

get_host :: () -> *Enet.Host {
    if host_type == .SERVER return server.host;
    if host_type == .CLIENT return client.host;
    return null;
}

init_server :: (server_port : u16) {
    log_verbose("init_server, server_port=%", server_port);
    host_type = .SERVER;

    success : bool;

    // Using 0 here makes Enet use its dynamic throttling algorithm to manage bandwidth
    bandwidth_bytes_per_second := 0;

    address : Enet.Address;
    address.host = Enet.HOST_ANY;
    address.port = server_port;
    server.host, success = Enet.host_create(
        address=*address,
        peer_count=1, // player_count-1, currently only 2 players are supported
        channel_limit=1,
        incoming_bandwidth=bandwidth_bytes_per_second,
        outgoing_bandwidth=bandwidth_bytes_per_second);

    assert(success, "Failed to create server!\n");
}

deinit_server :: () {
    log_verbose("deinit_server");

    for * peer: server.host.peers {
        Enet.peer_disconnect(peer, 0);
    }
    Enet.host_flush(server.host); // Flush since we're about destroy the host
    Enet.host_destroy(server.host);

    host_type = .UNKNOWN;
}

init_client :: (server_address : string, server_port : u16) {
    log_verbose("init_client, server_address:server_port=%:%", server_address, server_port);

    host_type = .CLIENT;

    success : bool;

    // Using 0 here makes Enet use its dynamic throttling algorithm to manage bandwidth
    bandwidth_bytes_per_second := 0;

    client.host, success = Enet.host_create(
        address=null,
        peer_count=1, // Can only connect to one server
        channel_limit=1,
        incoming_bandwidth=bandwidth_bytes_per_second,
        outgoing_bandwidth=bandwidth_bytes_per_second);
    assert(success, "Failed to create client!\n");

    address := Enet.get_host_ip_address(server_address);
    address.port = server_port;

    log("Connecting to server %:%", server_address, server_port);
    client.server = Enet.host_connect(host=client.host, address=*address, channel_count=1, data=0); 
}

deinit_client ::() {
    log_verbose("deinit_client");

    Enet.peer_disconnect(client.server, 0);
    Enet.host_flush(client.host);
    Enet.host_destroy(client.host);

    host_type = .UNKNOWN;
}


Player_State :: struct {
    shape : Paddle_Shape;

    transform : b2Transform;

    score : int;
};

Ball_State :: struct {
    shape : Ball_Shape;

    transform : b2Transform;

    live : bool;
};

Obstruction_State :: struct {
    transform : b2Transform;
}

Level_State :: struct {
    level_id : Level_Id; // @Cleanup Do we need this? We send it in Init_Game_State
    obstructions : Obstruction_State;
}

Init_Game_State :: struct {
    p1_paddle_shape : Paddle_Shape;
    p2_paddle_shape : Paddle_Shape;
    ball_shape : Ball_Shape;
    level_id : Level_Id;
} 

// @TODO Better way of distinguishing packets...!
#assert(size_of(Game_State) != size_of(Init_Game_State));
#assert(size_of(Game_State) != size_of(Client_Input));
#assert(size_of(Game_State) != size_of(Paddle_Shape));
#assert(size_of(Client_Input) != size_of(Init_Game_State));
#assert(size_of(Client_Input) != size_of(Paddle_Shape));
#assert(size_of(Paddle_Shape) != size_of(Init_Game_State));

// This data is sent by the server to all connected clients
// @TODO Generate the members using notes
Game_State :: struct {
    player1_state : Player_State;
    player2_state : Player_State;
    level_state : Level_State;
    ball_state : [BALL_COUNT_MAX]Ball_State;
}

Game_State_Delta :: struct {
    // TODOOOO Implement delta compression and send these instead
}


Client_Input :: struct {
    player_index : Player_Index;
    left_down : bool;
    right_down : bool;
    esc_down : bool;
}

get_ball_state :: (using ball : Ball) -> Ball_State {
    result : Ball_State;
    result.live = live;
    result.transform = b2Body.GetTransform(body);
    return result;
}

get_player_state :: (using player : Player) -> Player_State {
    result : Player_State;
    result.transform = b2Body.GetTransform(body);
    result.score = score;
    return result;
}

get_level_state :: () -> Level_State {
    result : Level_State;

    result.level_id = cast(Level_Id)current_level;
    if result.level_id != .Empty {
        result.obstructions.transform = b2Body.GetTransform(level.obstructions.body);
    }

    return result;
}

get_game_state :: () -> Game_State {
    result : Game_State;
    result.player1_state = get_player_state(player1);
    result.player2_state = get_player_state(player2);
    result.level_state = get_level_state();
    for ball : balls {
        result.ball_state[it_index] = get_ball_state(ball);
    }
    return result;
}

set_game_state :: (using state : Game_State) {
    player1.transform = player1_state.transform;
    player1.score = player1_state.score;

    player2.transform = player2_state.transform;
    player2.score = player2_state.score;

    current_level = xx level_state.level_id;
    if cast(Level_Id)current_level != .Empty {
        level.obstructions.transform = level_state.obstructions.transform;
    }

    for ball_state {
        ball := *balls[it_index];
        ball.live = it.live;
        ball.shape = it.shape;
        ball.transform = it.transform;
    }
}

init_host_info :: () {
    hostname0_found:, host_info.hostname = get_hostname0();
    assert(hostname0_found);

    ip_found:, host_info.ipv4 = get_host_info(host_info.hostname);
    assert(ip_found);

    host_info.port = DEFAULT_PORT;
}

// Returns a null-terminated hostname string (indicated by the 0)
get_hostname0 :: () -> bool, string {
    buffer : [256]u8;
    // Get the hostname
    if Socket.gethostname(buffer.data, buffer.count) == Socket.SOCKET_ERROR {
        // std::cerr << "Error getting hostname: " << WSAGetLastError() << std::endl;
        // WSACleanup();
        return false, "";
    }

    hostname0 := to_string(buffer.data);
    return true, copy_string(hostname0);
}

get_host_info :: (hostname : string) -> bool, u32 {
    hints : Socket.addrinfo;
    host_addrs : *Socket.addrinfo;
    defer Socket.freeaddrinfo(host_addrs);

    memset(*hints, 0, size_of(type_of(hints)));
    hints.ai_family = Socket.AF_INET;
    hints.ai_socktype = .SOCK_DGRAM;
    hints.ai_protocol = .IPPROTO_UDP;

    // Get host addresses
    if Socket.getaddrinfo(hostname.data, null, *hints, *host_addrs) != 0 {
        // std::cerr << "getaddrinfo failed: " << WSAGetLastError() << std::endl;
        // WSACleanup();
        // return 1;
        return false, 0;
    }

    ipv4 : u32;

    // Loop through all the addresses and print them
    a : *Socket.addrinfo = host_addrs;
    while a != null {
        endpoint := cast(*Socket.sockaddr_in)a.ai_addr;
        ipv4 = endpoint.sin_addr.S_un.S_addr;
        a = a.ai_next;
    }

    return true, ipv4;
}

read_network_events_this_frame_debug_count := 5;
read_network_events_this_frame :: ($debug : bool = false) {
    host_service_start_time := to_microseconds(current_time_monotonic());

    array_reset_keeping_memory(*network_events_this_frame);
    event : Enet.Event;

    // http://enet.bespin.org/Tutorial.html says we should use 0 here to returns immediately
    // but https://github.com/zpl-c/enet/issues/46 suggests using 2 is better
    timeout_milliseconds := 0;
    while Enet.host_service(get_host(), *event, timeout_milliseconds) == .SUCCESS {
        array_add(*network_events_this_frame, event);
    }

    #if debug {
        if host_type == .CLIENT printv(host_service_start_time);
        if network_events_this_frame {
            if host_type == .SERVER printv(host_service_start_time);

            read_network_events_this_frame_debug_count -= 1;
            if read_network_events_this_frame_debug_count < 0 exit(0);

            print("************************************\n");
            print("% got % events:\n", host_type, network_events_this_frame.count);
            for event : network_events_this_frame {
                if it_index > 10 { print("...\n"); break; }
                print_event(event, it_index);
            }
        }
    }
}

// Send input from client to server
send_input :: (input : Client_Input, loc := #caller_location) {
    countdown(*client_packet_countdown_ms);
    if client_packet_countdown_ms > 0  return;
    client_packet_countdown_ms = CLIENT_PACKET_COUNTDOWN_MS;


    // @TODO Ensure the client is connected
    
    // @Cleanuppp Rather that storing client.peer, can this be done line the server function via client.host.peers?
    packet := Enet.packet_create(*input, .RELIABLE); // @Leak?
    // packet.user_data.* = current_frame; // @Volatile Previously when I experimented with setting this everything broke, not just because this is clearly the wrong way to set an *Any
    Enet.peer_send(peer=client.server, channel_id=0, packet=packet);
    
    // Sleep(16); // @@?
}

// Send game state from server to client
send_state :: (player : Player, state : Game_State, loc := #caller_location) {
    countdown(*server_packet_countdown_ms);
    if server_packet_countdown_ms > 0  return;
    server_packet_countdown_ms = SERVER_PACKET_COUNTDOWN_MS;

    assert(server.host.peers.count == 1);
    // @Cleanup use Enet.host_broadcast here
    for * peer: server.host.peers {
        if peer.state == .CONNECTED {
            packet := Enet.packet_create(*state, .RELIABLE); // @Leak?
            Enet.peer_send(peer=peer, channel_id=0, packet=packet);
        }
    }
}

// Receive input sent from client to server
receive_input :: (loc := #caller_location) -> Client_Input, bool {

    input : Client_Input;
    found : bool;

    for event : network_events_this_frame {
        if event.type == .RECEIVE {
            defer Enet.packet_destroy(event.packet);
            if event.packet.data_length == size_of(Client_Input) {

                // Keep the most recent?
                input = (cast(*Client_Input)event.packet.data).*;
                found = true;
                // remove; // @Think Adding just this one line causes a crash in the default allocator, why???
            }
        }
    }

    return input, found;
}

// Receive game state sent from server to client
receive_state :: (loc := #caller_location) -> Game_State, bool {

    state : Game_State;
    found : bool;

    for event : network_events_this_frame {
        if event.type == .RECEIVE {
            defer Enet.packet_destroy(event.packet);
            if event.packet.data_length == size_of(Game_State) {

                // Keep the most recent?
                state = (cast(*Game_State)event.packet.data).*;
                found = true;
                // remove; // @Think Adding just this one line causes a crash in the default allocator, why???
            }
        }
    }

    return state, found;
}








// @Cleanup rename to ipv4_as_string

ipv4_to_string :: (ipv4 : u32) -> string {
    builder: String_Builder;
    Socket.append_address(*builder, ipv4);
    return builder_to_string(*builder);
}
