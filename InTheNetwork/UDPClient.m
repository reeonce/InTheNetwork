//
//  UDPClient.m
//  InTheNetwork
//
//  Created by Ree on 30/04/2017.
//  Copyright © 2017 reeonce. All rights reserved.
//

#import "UDPClient.h"
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>
#import <arpa/inet.h>
#import <fcntl.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <net/if.h>
#import <sys/socket.h>
#import <sys/types.h>

@interface UDPClient () <GCDAsyncUdpSocketDelegate>

@property (nonatomic) NSString *host;

@property (nonatomic) uint16_t port;

@property (nonatomic) NSData *address;

@property (nonatomic) GCDAsyncUdpSocket *socket;

@property (nonatomic) dispatch_queue_t delegateQueue;

@property (nonatomic) NSTimer *timer;

@end

@implementation UDPClient

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegateQueue = dispatch_queue_create("udp client delegate queue", DISPATCH_QUEUE_SERIAL);
        _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_delegateQueue];
    }
    return self;
}

- (void)connectTo:(NSString *)host port:(uint16_t)port {
    self.host = host;
    self.port = port;
    
    struct sockaddr_in ip4addr;
    ip4addr.sin_family = AF_INET;
    ip4addr.sin_port = htons(port);
    inet_pton(AF_INET, [host cStringUsingEncoding:NSASCIIStringEncoding], &ip4addr.sin_addr);
    self.address = [NSData dataWithBytes:&ip4addr length:sizeof(ip4addr)];
    
//    [_socket performBlock:^{
//        int n = 0;
//        unsigned int m = sizeof(n);
////        setsockopt(_socket.socketFD, SOL_SOCKET, SO_SNDBUF, (void *)&n, m);
//        getsockopt(_socket.socketFD, SOL_SOCKET, SO_SNDBUF, (void *)&n, &m);
//        NSLog(@"receive buffer size: %d", n);
//    }];
//    [_socket connectToHost:host onPort:port error:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendData];
    });
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendData];
    });
}

- (void)sendData {
    NSInteger length = 32 * 1024;
    void *bytes = malloc(length);
    NSData *data = [NSData dataWithBytesNoCopy:bytes length:length];
    while (YES) {
        [self sendData:data];
    }
}

- (void)sendData:(NSData *)data {
//    [_socket sendData:timer.userInfo toAddress:self.address withTimeout:-1 tag:0];
    [_socket sendData:data toHost:self.host port:self.port withTimeout:-1 tag:0];
//    [_socket sendData:timer.userInfo withTimeout:-1 tag:0];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
//    NSLog(@"didSendDataWithTag");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
//    NSLog(@"didNotSendDataWithTag, %@", error);
}

@end
