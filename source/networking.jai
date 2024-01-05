Host_Info :: struct {
    hostname : string;
    ipv4 : u32;
    port : u16 = DEFAULT_PORT; // nocommit Make this editable in the UI
}

Player_State :: struct {
    index : Player_Index;
    position : float; // In the "player coordinate system" where left/right are determined by direction player is facing
};

Ball_State :: struct {
    position : Vector2;
    rotation : float;
    //velocity : Vector2;
};

Level_State :: struct {
    level : Level_Id;
}

Game_State :: struct {
    menu : Game_Menu;

    // @TODO Only send these when game starts?
    ball_shape : Ball_Shape;
    paddle_shape : Paddle_Shape;
}

// This data is sent by the server to all connected clients
// @TODO Generate the members using notes
Server_State :: struct {
    // A number representing the game protocol hashed with the protocol version number
    // all UDP packages have the first 4 bytes inspected, packets with numbers not matching
    // this protocol_id are discarded, otherwise we parse the rest of the payload
    protocol_id : u32 = 4269;

    player1_state : Player_State;
    player2_state : Player_State;
    ball_state : Ball_State; // @Incomplete support more than one ball
    level_state : Level_State;
    game_state : Game_State;
}

Client_Input :: struct {
    left_down : bool;
    right_down : bool;
}

get_player_state :: (using player : Player) -> Player_State {
    result : Player_State;
    p := apply_transform(b2Body.GetTransform(body), b2Body.GetWorldCenter(body));
    result.position = p.x;
    result.index = index;
    return result;
}

get_game_state :: () -> Game_State {
    result : Game_State;
    result.menu = game_menu;
    result.ball_shape = xx current_ball_shape;
    result.paddle_shape = xx current_paddle_shape;
    return result;
}

init_host_info :: () {
    hostname0_found:, host_info.hostname = get_hostname0();
    assert(hostname0_found);

    ip_found:, host_info.ipv4 = get_host_info(host_info.hostname);
    assert(ip_found);
}

// nocommit rename
init_host_socket :: (ipv4 : u32, port : u16) -> Socket.SOCKET #must {
    // Create a IPv4 UDP socket
    socket := Socket.socket(Socket.AF_INET, .SOCK_DGRAM, .IPPROTO_UDP);
    if socket == Socket.INVALID_SOCKET {
        error := Socket.get_last_socket_error();
        log_error("Socket.socket error: %", System.get_error_string(xx error));
        assert(false);
    }

    ipv4_string := ipv4_to_string(ipv4,,temp);

    // Associate the host address with the socket
    if Socket.bind(socket, ipv4_string, port) == Socket.SOCKET_ERROR {
        error := Socket.get_last_socket_error();
        log_error("Socket.bind error: %", System.get_error_string(xx error));
        assert(false);
    }

    // Prevent the socket from blocking when calling recvfrom
    Socket.set_blocking(socket, false);

    // Enable broadcast permissions since we call sendto
    enable_broadcast : s32 = 1;
    if Socket.setsockopt(socket, Socket.SOL_SOCKET, Socket.SO_BROADCAST, cast(*u8)*enable_broadcast, size_of(type_of(enable_broadcast))) < 0 {
        error := Socket.get_last_socket_error();
        log_error("Socket.setsockopt error: %", System.get_error_string(xx error));
        assert(false);
    }

    return socket;
}

Endpoint :: Socket.sockaddr_in;

ipv4_to_string :: (ipv4 : u32) -> string {
    builder: String_Builder;
    Socket.append_address(*builder, ipv4);
    return builder_to_string(*builder);
}

ipv4_to_u32 :: (ipv4 : string) -> u32 {
    return Socket.inet_addr(ipv4.data);
}

get_endpoint :: (ipv4 : string, port : u16) -> Endpoint {
    result : Socket.sockaddr_in;
    result.sin_family = Socket.AF_INET;
    result.sin_port = Socket.htons(port); // Convert to network byte order
    result.sin_addr.S_un.S_addr = Socket.inet_addr(ipv4.data);
    return result;
}

get_ipv4 :: (endpoint : Endpoint) -> u32, string {
    ipv4 := endpoint.sin_addr.S_un.S_addr;
    ipv4_string := copy_string(Socket.to_string(endpoint));
    return ipv4, ipv4_string;
}


// @Cleanup Move this into the Socket module. See https://gafferongames.com/post/sending_and_receiving_packets/
socket_deinit :: () -> bool {
    System :: #import "System";
    #import "Windows";

    #if OS == .WINDOWS {
        result := Socket.WSACleanup();
        if result == Socket.SOCKET_ERROR {
            log_error("Could not terminate Winsock2: % %", result, System.get_error_string(cast (OS_Error_Code)result));
            return false;
        }
    } else {
        // Nothing to do on Unix
    }

    return true;
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