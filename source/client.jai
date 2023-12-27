#import "Basic";
Socket :: #import "Socket";
System :: #import "System";

// This is the client

main :: () {

    port : u16 = 55555;
    // Note: "localhost" is not supported by Socket.bind (Socket module.jai) since it calls inet_addr which does not support "localhost"
    //socket_address := "127.0.0.1";
    socket_address := "0.0.0.0";
    server_hostname : string = "0.0.0.0";
    assert(Socket.inet_addr("0.0.0.0") == Socket.INADDR_ANY); // Just a test


    Socket.socket_init();
    defer {
        #if OS == .WINDOWS {
            Socket.WSACleanup();
        }
    }

    send_socket : Socket.SOCKET = Socket.socket(Socket.AF_INET, .SOCK_DGRAM, .IPPROTO_UDP);
    if send_socket == Socket.INVALID_SOCKET {
        error := Socket.get_last_socket_error();
        log_error("invalid socket: %", System.get_error_string(xx error));
        return;
    }

    send_buf : [1024]u8;
    message := "Maryna is the best";
    for 0..message.count-1 {
        send_buf[it] = message[it];
    }

    server_addr : Socket.sockaddr_in;
    server_addr.sin_family = Socket.AF_INET;
    server_addr.sin_port = Socket.htons(port);
    server_addr.sin_addr.S_un.S_addr = Socket.inet_addr("127.0.0.1");// nocommit
    print("Sending a datagram to the receiver...\n");
    sent_bytes : s32 = Socket.sendto(send_socket, send_buf.data, send_buf.count, 0, cast(*Socket.SOCKADDR) *server_addr, size_of(type_of(server_addr)));
    if (sent_bytes == Socket.SOCKET_ERROR) {
        error := Socket.get_last_socket_error();
        print("error = %\n", error);
        log_error("Socket.sendto error: %", System.get_error_string(xx error));
        // wprintf(L"sendto failed with error: %d\n", WSAGetLastError());
        // closesocket(SendSocket);
        // WSACleanup();
        // return 1;
    }

    // send(client_socket, sent.data, sent.count, .BCAST);
    // sendto(client_socket, sent.data, sent.count, .BCAST, null, 0);
    //sendto :: (s: SOCKET, buf: *u8, len: s32, flags: MSG, to: *sockaddr, tolen: s32) -> s32 #foreign ws2_32;

    // received : string;
    // recv(client_socket, received.data, received.count);

    // print("Received: '%'", received);

    // modifiedSentence = clientSocket.recv(1024)
    // print(’From Server: ’, modifiedSentence.decode())
    // client_socket.close();
}
