Host_Info :: struct {
    hostname : string;
    ipv4 : u32;
    port : u16 = DEFAULT_PORT; // This is configurable
}

Player_State :: struct {
    shape : Paddle_Shape;

    // nocommit cleanup
    // ition : Vector2; // In the "player coordinate system" where left/right are determined by direction player is facing
    transform : b2Transform;

    score : int;
};

Ball_State :: struct {
    shape : Ball_Shape;

    transform : b2Transform;
    //velocity : Vector2;

    live : bool;
};

Level_State :: struct {
    level : Level_Id;
}

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


// nocommit
Packet :: struct {
    // A number representing the game protocol hashed with the protocol version number
    // all UDP packages have the first 4 bytes inspected, packets with numbers not matching
    // this protocol_id are discarded, otherwise we parse the rest of the payload
    protocol_id : u32 = 4269;
    type : Type; // [Server_State, Client_Input...] Cast the specific packets to this type
}

Client_Input :: struct {
    player_index : Player_Index;
    left_down : bool;
    right_down : bool;
    esc_down : bool;
}

// @TODOOO Send the transform (position/orientation)
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

// Send input from client to server
send_input :: (input : Client_Input, loc := #caller_location) {
    // @TODO Ensure the client is connected
    
    // @Cleanuppp Rather that storing client.peer, can this be done line the server function via client.host.peers?
    packet := Enet.packet_create(*input, .RELIABLE);
    Enet.peer_send(peer=client.peer, channel_id=0, packet=packet);
    
    // Sleep(16); // @@nocommit??
}

// Send game state from server to client
send_state :: (player : Player, state : Game_State, loc := #caller_location) {
    assert(server.host.peers.count == 1);
    for * peer: server.host.peers {
        if peer.state == .CONNECTED {
            packet := Enet.packet_create(*state, .RELIABLE);
            Enet.peer_send(peer=peer, channel_id=0, packet=packet);
        }
    }
}

// Receive input sent from client to server
receive_input :: (loc := #caller_location) -> Client_Input, bool {

    for event : network_events_this_frame {
        if event.type == .RECEIVE {
            if event.packet.data_length == size_of(Client_Input) {

                input : Client_Input = (cast(*Client_Input)event.packet.data).*;
                Enet.packet_destroy(event.packet);
                remove;

                return input, true;
            }
        }
    }

    return .{}, false;
}

// Receive game state sent from server to client
receive_state :: (loc := #caller_location) -> Game_State, bool {

    for event : network_events_this_frame {
        if event.type == .RECEIVE {
            if event.packet.data_length == size_of(Game_State) {

                state := (cast(*Game_State)event.packet.data).*;
                Enet.packet_destroy(event.packet);
                remove;

                return state, true;
            }
        }
    }

    return .{}, false;
}






Server :: struct {
    using host : *Enet.Host;
}

init_server :: (server_port : u16) {
    host_type = .SERVER;

    success : bool;

    address : Enet.Address;
    address.host = Enet.HOST_ANY;
    address.port = server_port;
    server.host, success = Enet.host_create(
        address=*address,
        peer_count=1, 
        channel_limit=1,
        // Using 0 here makes Enet use its dynamic throttling algorithm to manage bandwidth
        incoming_bandwidth=0,
        outgoing_bandwidth=0);

    assert(success, "Failed to create server!\n");
}

deinit_server :: () {
    host_type = .UNKNOWN;
    Enet.host_destroy(server.host);
}



Client :: struct {
    using host : *Enet.Host;
    peer : *Enet.Peer;
}

init_client :: (server_address : string, server_port : u16) {
    host_type = .CLIENT;

    success : bool;

    client.host, success = Enet.host_create(
        address=null,
        peer_count=1,
        channel_limit=1,
        // Using 0 here makes Enet use its dynamic throttling algorithm to manage bandwidth
        incoming_bandwidth=0,
        outgoing_bandwidth=0);
    assert(success, "Failed to create server!\n");

    address := Enet.get_host_ip_address(server_address);
    address.port = server_port;

    print("Connecting to server %:%\n", server_address, server_port);
    client.peer = Enet.host_connect(host=client.host, address=*address, channel_count=1, data=0); 
}

deinit_client ::() {
    host_type = .UNKNOWN;
    Enet.host_destroy(client.host);
}


// @Cleanup rename to ipv4_as_string

ipv4_to_string :: (ipv4 : u32) -> string {
    builder: String_Builder;
    Socket.append_address(*builder, ipv4);
    return builder_to_string(*builder);
}
