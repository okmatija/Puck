#import "Basic";
Socket :: #import "Socket";
String :: #import "String";
Windows :: #import "Windows"; // For OS_Error_Code
System :: #import "System";

#load "carpet.jai";

// This is the server



main :: () {

    port : u16 = 5555; // @Cleaup Use 0 here to get an OS allocated socket?
    // Note: "localhost" is not supported by Socket.bind (Socket module.jai) since it calls inet_addr which does not support "localhost"
    socket_address := "127.0.0.1";
    // socket_address := "0.0.0.0";
    assert(Socket.inet_addr("0.0.0.0") == Socket.INADDR_ANY); // Just a test


    Socket.socket_init();
    defer socket_deinit();

    server_socket : Socket.SOCKET = Socket.socket(Socket.AF_INET, .SOCK_DGRAM, .IPPROTO_UDP);
    if server_socket == Socket.INVALID_SOCKET {
        error := Socket.get_last_socket_error();
        log_error("Socket.socket error: %", System.get_error_string(xx error));
        return;
    }

    if Socket.bind(server_socket, socket_address, port) == Socket.SOCKET_ERROR {
        error := Socket.get_last_socket_error();
        log_error("Socket.bind error: %", System.get_error_string(xx error));
        return;
    }

    Socket.set_blocking(server_socket, false);
    // //-------------------------
    // // Set the socket I/O mode: In this case FIONBIO
    // // enables or disables the blocking mode for the 
    // // socket based on the numerical value of iMode.
    // // If iMode = 0, blocking is enabled; 
    // // If iMode != 0, non-blocking mode is enabled.

    // iResult = ;
    // if Socket.ioctlsocket(server_socket, .FIONBIO, &iMode) == Socket.SOCKET_ERROR {
    // printf("ioctlsocket failed with error: %ld\n", iResult);
    // }

    print("Receiving datagrams...\n");

    while true {
        sender_addr : Socket.SOCKADDR;
        sender_addr_size : s32 = size_of(Socket.SOCKADDR);

        // Note: Any packet larger than this buffer will be silently discarded!
        packet_buffer : [1024]u8;

        packet_size : s32 = Socket.recvfrom(server_socket, packet_buffer.data, packet_buffer.count, 0, *sender_addr, *sender_addr_size);
        if packet_size == Socket.SOCKET_ERROR {
            error := Socket.get_last_socket_error();
            if error == Socket.SOCKET_WOULDBLOCK {
                // No data to be read from the socket
            } else {
                print("error = %\n", error);
                log_error("Socket.recvfrom error: %", System.get_error_string(xx error));
                return;
            }
        }

        packet : []u8;
        packet.data = packet_buffer.data;
        packet.count = max(packet_size, 0);
        received_string : string = cast(string)packet;
        print("received_string = '%'\n", received_string);

        to_upper :: (s: string) -> string {
            copy := copy_string(s);
            String.to_upper_in_place(copy);
            return copy;
        }

        Sleep(200);

        reply := to_upper(received_string);
        // Socket.send(server_socket, reply.data, xx reply.count, .BCAST);
        // print("reply = '%'\n", reply);

    }

    /*
    while true { 
        // connectionSocket, addr = serverSocket.accept()

        sentence = connectionSocket.recv(1024).decode()
        capitalizedSentence = sentence.upper()
        connectionSocket.send(capitalizedSentence.encode())
        connectionSocket.close()
    }
    */

    /*
    socket();
    bind();
    listen();
    accept(); connect();
    recv(); send(); recvfrom(); sendto();
    closesocket();
    */

    Socket.close_and_reset(*server_socket);

}
