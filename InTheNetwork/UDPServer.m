//
//  UDPServer.m
//  InTheNetwork
//
//  Created by Ree on 30/04/2017.
//  Copyright © 2017 reeonce. All rights reserved.
//

#import "UDPServer.h"
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface UDPServer () <GCDAsyncUdpSocketDelegate>

@property (nonatomic) dispatch_queue_t delegateQueue;

@property (nonatomic) GCDAsyncUdpSocket *socket;

@property (nonatomic) uint16_t port;

@property (nonatomic) NSDate *lastRecordTime;

@property (nonatomic) NSInteger receivedLength;

@end

@implementation UDPServer


- (instancetype)initWithPort:(uint16_t)port {
    self = [super init];
    if (self) {
        _delegateQueue = dispatch_queue_create("udp delegate queue", DISPATCH_QUEUE_SERIAL);
        _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_delegateQueue];
        _port = port;
    }
    return self;
}

- (void)start {
    [self.socket bindToPort:_port error:nil];
    
    [self.socket beginReceiving:nil];
    _lastRecordTime = [NSDate date];
    _receivedLength = 0;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    _receivedLength += data.length;
    NSTimeInterval interval = -[_lastRecordTime timeIntervalSinceNow];
    if (interval > 5) {
        NSLog(@"speed: %f MB/s", _receivedLength / interval / 1024 / 1024);
        _receivedLength = 0;
        _lastRecordTime = [NSDate date];
    }
}

@end
