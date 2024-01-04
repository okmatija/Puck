Socket :: #import "Socket";
System :: #import "System";

#import "Basic";
#import "Math";
#load "carpet.jai";

// This is the client

main :: () {

    port : u16 = 5555;
    // Note: "localhost" is not supported by Socket.bind (Socket module.jai) since it calls inet_addr which does not support "localhost"
    //socket_address := "127.0.0.1";
    // socket_address := "0.0.0.0";
    // server_hostname : string = "0.0.0.0";
    // assert(Socket.inet_addr("0.0.0.0") == Socket.INADDR_ANY); // Just a test


    Socket.socket_init();
    defer socket_deinit();

    send_socket : Socket.SOCKET = Socket.socket(Socket.AF_INET, .SOCK_DGRAM, .IPPROTO_UDP);
    if send_socket == Socket.INVALID_SOCKET {
        error := Socket.get_last_socket_error();
        log_error("invalid socket: %", System.get_error_string(xx error));
        return;
    }

    Data :: struct {
        player_position : Vector2;
        ball_position : Vector2;
    }    

    server_addr : Socket.sockaddr_in;
    server_addr.sin_family = Socket.AF_INET;
    server_addr.sin_port = Socket.htons(port);
    server_addr.sin_addr.S_un.S_addr = Socket.inet_addr("127.0.0.1");

    send_string :: (data : []u8, send_socket : Socket.SOCKET, dest_addr : Socket.sockaddr_in) {
        // print("Sending a datagram to the receiver...\n");

        // @Cleanup use packet to name the sent data
        // Note: sendto returning successfully only means the packet was sent from the local computer, UDP does not guarantee that the data was recieved by the recipient
        sent_bytes : s32 = Socket.sendto(send_socket, data.data, cast(s32)data.count, 0, cast(*Socket.SOCKADDR) *dest_addr, size_of(type_of(dest_addr)));
        if (sent_bytes == Socket.SOCKET_ERROR) {
            error := Socket.get_last_socket_error();
            print("error = %\n", error);
            log_error("Socket.sendto error: %", System.get_error_string(xx error));
            // wprintf(L"sendto failed with error: %d\n", WSAGetLastError());
            // closesocket(SendSocket);
            // WSACleanup();
            // return 1;
        }
    }

    send_string(xx "What the heck", send_socket, server_addr);
    send_string(xx "The second message", send_socket, server_addr);
    send_string(xx "Three is my favourite number", send_socket, server_addr);

    // send(client_socket, sent.data, sent.count, .bcast);
    // sendto(client_socket, sent.data, sent.count, .bcast, null, 0);
    //sendto :: (s: socket, buf: *u8, len: s32, flags: msg, to: *sockaddr, tolen: s32) -> s32 #foreign ws2_32;

    // received : string;
    // recv(client_socket, received.data, received.count);

    // print("received: '%'", received);

    // modifiedsentence = clientsocket.recv(1024)
    // print(’from server: ’, modifiedsentence.decode())
    // client_socket.close();
}
