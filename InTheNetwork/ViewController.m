//
//  ViewController.m
//  InTheNetwork
//
//  Created by Ree on 28/04/2017.
//  Copyright © 2017 reeonce. All rights reserved.
//

#import "ViewController.h"
//#import "Socket.hpp"
#import "TCPServer.h"
#import "TCPClient.h"
#import "UDPServer.h"
#import "UDPClient.h"

#define TCP_SERVER_PORT 6666
#define UDP_SERVER_PORT 6667

@interface ViewController ()

@property (nonatomic) TCPServer *server;

@property (nonatomic) TCPClient *client;

@property (nonatomic) UDPServer *udpServer;

@property (nonatomic) UDPClient *udpClient;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    int size = Socket::buffer_size();
//    NSLog(@"buffer size: %d", size);
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    self.server = [[TCPServer alloc] initWithPort:(TCP_SERVER_PORT)];
    self.client = [[TCPClient alloc] init];
    
    self.udpServer = [[UDPServer alloc] initWithPort:(UDP_SERVER_PORT)];
    self.udpClient = [[UDPClient alloc] init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleServer:(id)sender {
    [self.server start];
    [self sendData];
    
//    [self.udpServer start];
}

- (IBAction)handleClient:(id)sender {
//    [self.client connectTo:@"172.20.10.2" port:TCP_SERVER_PORT];
//    [self.client connectTo:@"192.168.199.232" port:TCP_SERVER_PORT];
    [self.client connectTo:@"192.168.2.1" port:TCP_SERVER_PORT];
    
//    [self.udpClient connectTo:@"192.168.199.114" port:UDP_SERVER_PORT];
}

- (void)sendData {
    NSInteger length = 1 * 1024 * 1024;
    void *bytes = malloc(length);
    NSData *data = [NSData dataWithBytesNoCopy:bytes length:length];
    [NSTimer scheduledTimerWithTimeInterval:0.03 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self.server sendData:data];
    }];
}

- (IBAction)aaa:(id)sender {
}
@end
