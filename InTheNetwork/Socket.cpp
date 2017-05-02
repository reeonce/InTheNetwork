//
//  Socket.cpp
//  InTheNetwork
//
//  Created by Ree on 28/04/2017.
//  Copyright © 2017 reeonce. All rights reserved.
//

#include "Socket.hpp"
#include <sys/socket.h>

int Socket::buffer_size() {
    int n;
    unsigned int m = sizeof(n);
    int fdsocket;
    fdsocket = socket(AF_INET, SOCK_DGRAM, 2); // example
    getsockopt(fdsocket, SOL_SOCKET, SO_RCVBUF, (void *)&n, &m);
    return n;
}
