#import "Basic";
Socket :: #import "Socket";
String :: #import "String";
Windows :: #import "Windows"; // For OS_Error_Code
System :: #import "System";

#load "carpet.jai";

// This is the server



main :: () {

    port : u16 = 55555;
    // Note: "localhost" is not supported by Socket.bind (Socket module.jai) since it calls inet_addr which does not support "localhost"
    socket_address := "127.0.0.1";
    // socket_address := "0.0.0.0";
    assert(Socket.inet_addr("0.0.0.0") == Socket.INADDR_ANY); // Just a test


    Socket.socket_init();
    defer {
        #if OS == .WINDOWS {
            Socket.WSACleanup();
        }
    }

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

    print("Receiving datagrams...\n");

    while true {
        sender_addr : Socket.SOCKADDR;
        sender_addr_size : s32 = size_of(Socket.SOCKADDR);
        received_buf : [1024]u8;

        received_bytes : s32 = Socket.recvfrom(server_socket, received_buf.data, received_buf.count, 0, *sender_addr, *sender_addr_size);
        if received_bytes == Socket.SOCKET_ERROR {
            error := Socket.get_last_socket_error();
            print("error = %\n", error);
            log_error("Socket.recvfrom error: %", System.get_error_string(xx error));
            return;
        }

        print("recieved_bytes = %\n", received_bytes);
        received : string = to_string(received_buf.data);
        print("received = '%'\n", received);

        to_upper :: (s: string) -> string {
            copy := copy_string(s);
            String.to_upper_in_place(copy);
            return copy;
        }

        reply := to_upper(received);
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
