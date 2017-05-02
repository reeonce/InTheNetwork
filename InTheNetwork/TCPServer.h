//
//  TCPServer.h
//  InTheNetwork
//
//  Created by Ree on 29/04/2017.
//  Copyright © 2017 reeonce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPServer : NSObject

- (instancetype)initWithPort:(uint16_t)port;

- (void)start;

- (void)sendData:(NSData *)data;

@end
