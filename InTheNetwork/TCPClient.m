//
//  TCPClient.m
//  InTheNetwork
//
//  Created by Ree on 29/04/2017.
//  Copyright © 2017 reeonce. All rights reserved.
//

#import "TCPClient.h"
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface TCPClient () <GCDAsyncSocketDelegate>

@property (nonatomic) dispatch_queue_t delegateQueue;
@property (nonatomic) GCDAsyncSocket *socket;

@property (nonatomic) NSString *host;

@property (nonatomic) uint16_t port;

@property (nonatomic) NSDate *lastRecordTime;

@property (nonatomic) NSInteger receivedLength;

@end

@implementation TCPClient

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegateQueue = dispatch_queue_create("client delegate queue", DISPATCH_QUEUE_SERIAL);
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_delegateQueue];
    }
    return self;
}

- (void)setup {
    [_socket performBlock:^{
        int n = 1097848;
        unsigned int m = sizeof(n);
        setsockopt(_socket.socketFD, SOL_SOCKET, SO_RCVBUF, (void *)&n, m);
        getsockopt(_socket.socketFD, SOL_SOCKET, SO_RCVBUF, (void *)&n, &m);
        NSLog(@"receive buffer size: %d", n);
    }];
}

- (void)connectTo:(NSString *)host port:(uint16_t)port {
    
    _host = host;
    _port = port;
    
    NSError *error;
    [_socket connectToHost:host onPort:port error:&error];
    NSLog(@"connect:%@", error);
    
    _lastRecordTime = [NSDate date];
    _receivedLength = 0;
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"socket did connect to %@:%u", host, port);
    [self setup];
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    _receivedLength += data.length;
    NSTimeInterval interval = -[_lastRecordTime timeIntervalSinceNow];
    if (interval > 5) {
        NSLog(@"speed: %f MB/s", _receivedLength / interval / 1024 / 1024);
        _receivedLength = 0;
        _lastRecordTime = [NSDate date];
    }
    
//    [sock writeData:data withTimeout:-1 tag:0];
    
    [sock readDataWithTimeout:-1 tag:0];
}

@end
