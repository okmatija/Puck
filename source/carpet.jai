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

Host_Info :: struct {
    hostname : string;
    ipv4 : u32;
    ipv4_string : string;
}

get_host_info :: (hostname : string) -> bool, u32, string {
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
        return false, 0, "";
    }

    ipv4 : u32;
    ipv4_string : string;

    // Loop through all the addresses and print them
    a : *Socket.addrinfo = host_addrs;
    while a != null {
        ipstr : [Socket.INET_ADDRSTRLEN]u8;
        sai := cast(*Socket.sockaddr_in)a.ai_addr;
        ipv4 = sai.sin_addr.S_un.S_addr;
        ipv4_string = Socket.to_string(sai);

        // Socket.inet_ntop(Socket.AF_INET, *sai.sin_addr, ipstr.data, size_of(type_of(ipstr)));
        // ip_addr := cast(string)ipstr;// string = to_string(ipstr);
        // ipv4_string = copy_string(ip_addr);
        // ipv4 = sai.sin_addr.S_un.S_addr;

        a = a.ai_next;
    }

    return true, ipv4, ipv4_string;
}

to_radians :: (degrees : float) -> float {
    scale :: PI / 180;
    return degrees * scale;
}

to_degrees :: (radians : float) -> float {
    scale :: 180 / PI;
    return radians * scale;
}

get_enum_count :: ($enum_type : Type) -> s64 {
    info := type_info(enum_type);
    assert(info.type == Type_Info_Tag.ENUM);
    info_enum := cast(*Type_Info_Enum) info;
    return info_enum.values.count;
}

printd :: ($a : string, loc := #caller_location) #expand {
    v := #insert a;
    s := a;
    s.count -= 1;
    print("%:% % = %\n", loc.fully_pathed_filename, loc. line_number, s, v);
}

printv :: (a : Code, loc := #caller_location) #expand {

    get_ident_name :: (code : Code) -> string {
        #import "Compiler";
        root := compiler_get_nodes(code);
        assert(root.kind == .IDENT);
        ident := cast(*Code_Ident) root;
        return ident.name;
    }

    new_context := context;

    //format_float := *new_context.print_style.default_format_float;
    //format_float.mode = .SCIENTIFIC;
    //format_float.width = 10;

    format_struct := *new_context.print_style.default_format_struct;
    format_struct.use_long_form_if_more_than_this_many_members = 4;
    format_struct.use_newlines_if_long_form = true;

    //format_array := *new_context.print_style.default_format_array;
    //format_array.stop_printing_after_this_many_elements = 10;

    push_context new_context {
#if true {
    print("%:% % = %\n", loc.fully_pathed_filename, loc.line_number, #run get_ident_name(a), #insert a);
} else {
    print("% = %\n", #run get_ident_name(a), #insert a);
}
    }
}

show_cursor :: inline ()
{
	#if OS == .WINDOWS
	{
		win32 :: #import "Windows";
		win32.ShowCursor (1);
	}
	else
	{
		// @Todo!
	}
}

hide_cursor :: inline ()
{
	#if OS == .WINDOWS
	{
		win32 :: #import "Windows";
		win32.ShowCursor (0);
	}
	else
	{
		// @Todo!
	}
}

#import "Math";