//
//  TCPServer.m
//  InTheNetwork
//
//  Created by Ree on 29/04/2017.
//  Copyright © 2017 reeonce. All rights reserved.
//

#import "TCPServer.h"
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

typedef struct Element {
    int identifier;
    NSTimeInterval timestamp;
}Element;

typedef struct Queue {
    int front;
    int tail;
    Element elements[10000];
}Queue;

@interface TCPServer () <GCDAsyncSocketDelegate>

@property (nonatomic) uint16_t port;

@property (nonatomic) GCDAsyncSocket *serverSocket;

@property (nonatomic) GCDAsyncSocket *clientSocket;

@property (nonatomic) dispatch_queue_t delegateQueue;

@property (nonatomic) Queue queue;

@property (nonatomic) NSTimeInterval timeInterval;

@end

@implementation TCPServer

- (instancetype)initWithPort:(uint16_t)port {
    self = [super init];
    if (self) {
        _port = port;
        _delegateQueue = dispatch_queue_create("server delegate queue", DISPATCH_QUEUE_SERIAL);
        _serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_delegateQueue];
        _queue.front = 0;
        _queue.tail = 0;
        _timeInterval = 0;
    }
    return self;
}

- (void)start {
    NSError *error;
    [_serverSocket acceptOnPort:6666 error:&error];
    NSLog(@"connect:%@", error);
    
    [_serverSocket performBlock:^{
        int n = 2052008;
        unsigned int m = sizeof(n);
        setsockopt(_serverSocket.socketFD, SOL_SOCKET, SO_SNDBUF, (void *)&n, m);
        getsockopt(_serverSocket.socketFD, SOL_SOCKET, SO_SNDBUF, (void *)&n, &m);
        NSLog(@"serverSocket send buffer size: %d", n);
    }];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(send) userInfo:nil repeats:YES];
//    });
}

- (void)send {
    if (!self.clientSocket) {
        return;
    }
    
    int number = _queue.front;
    NSData *data = [NSData dataWithBytes:&number length:sizeof(number)];
    [self.clientSocket writeData:data withTimeout:-1 tag:number];
    
    _queue.elements[_queue.front].identifier = number;
    _queue.elements[_queue.front].timestamp = [NSDate date].timeIntervalSince1970;
    _queue.front = (_queue.front + 1) % sizeof(_queue.elements);
}

- (void)parseNumber:(int)number {
    NSInteger identifier = _queue.elements[_queue.tail].identifier;
    NSTimeInterval timestamp = _queue.elements[_queue.tail].timestamp;
    if (number == identifier) {
        _queue.tail = (_queue.tail + 1) % sizeof(_queue.elements);
        NSTimeInterval receiveTimestamp = [NSDate date].timeIntervalSince1970;
        NSTimeInterval interval = receiveTimestamp - timestamp;
        NSLog(@"receive %d with s:%f, r:%f, interval:%f", number, timestamp, receiveTimestamp, interval);
        
        self.timeInterval += interval;
        
        if (number % 100 == 99) {
            NSLog(@"avg interval %f", self.timeInterval / 100);
            self.timeInterval = 0;
        }
    }
}

- (void)parseData:(NSData *)data {
    NSInteger offset = 0;
    do {
        int number = 0;
        [data getBytes:&number range:NSMakeRange(offset, sizeof(number))];
        offset += sizeof(number);
        [self parseNumber:number];
    } while (data.length > offset);
}

- (void)sendData:(NSData *)data {
    if (self.clientSocket) {
        [self.clientSocket writeData:data withTimeout:-1 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"accept");
    
    [newSocket performBlock:^{
        int n = 0;
        unsigned int m = sizeof(n);
//        setsockopt(newSocket.socketFD, SOL_SOCKET, SO_SNDBUF, (void *)&n, m);
        getsockopt(newSocket.socketFD, SOL_SOCKET, SO_SNDBUF, (void *)&n, &m);
        NSLog(@"send buffer size: %d", n);
        
        self.clientSocket = newSocket;
    }];
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
//    [self parseData:[data copy]];
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
//    [self parseNumber:(int)tag];
}

@end
