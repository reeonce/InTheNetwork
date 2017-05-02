//
//  UDPServer.h
//  InTheNetwork
//
//  Created by Ree on 30/04/2017.
//  Copyright © 2017 reeonce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDPServer : NSObject

- (instancetype)initWithPort:(uint16_t)port;

- (void)start;

@end
