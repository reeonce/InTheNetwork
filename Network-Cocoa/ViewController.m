//
//  ViewController.m
//  Network-Cocoa
//
//  Created by Ree on 30/04/2017.
//  Copyright © 2017 reeonce. All rights reserved.
//

#import "ViewController.h"
#import "TCPServer.h"
#import "TCPClient.h"

#define TCP_SERVER_PORT 6666

@interface ViewController ()

@property (nonatomic) TCPServer *server;

@property (nonatomic) TCPClient *client;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.server = [[TCPServer alloc] initWithPort:(TCP_SERVER_PORT)];
    
    self.client = [[TCPClient alloc] init];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)handleServer:(id)sender {
    [self.server start];
    
    [self sendData];
}

- (IBAction)handleClient:(id)sender {
    //    [self.client connectTo:@"172.20.10.2" port:TCP_SERVER_PORT];
    [self.client connectTo:@"192.168.199.114" port:TCP_SERVER_PORT];
}

- (void)sendData {
    NSInteger length = 1 * 1024 * 1024;
    void *bytes = malloc(length);
    NSData *data = [NSData dataWithBytesNoCopy:bytes length:length];
    [NSTimer scheduledTimerWithTimeInterval:0.03 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self.server sendData:data];
    }];
}


@end
