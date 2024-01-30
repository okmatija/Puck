debug_network_game :: () {
    is_network_game := host_type == .CLIENT || host_type == .SERVER;
    if is_network_game {
        printv(host_type);
        log("incoming_bandwidth = %\n", get_host().incoming_bandwidth);
        log("outgoing_bandwidth = %\n", get_host().outgoing_bandwidth);
        log("total_sent_packets = %\n", get_host().total_sent_packets);
        log("total_sent_data = %\n", get_host().total_sent_data);
        log("total_received_data_length = %\n", get_host().total_received_data_length);
    }
}