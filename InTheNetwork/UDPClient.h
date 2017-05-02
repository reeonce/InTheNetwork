//
//  UDPClient.h
//  InTheNetwork
//
//  Created by Ree on 30/04/2017.
//  Copyright © 2017 reeonce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDPClient : NSObject

- (void)connectTo:(NSString *)host port:(uint16_t)port;

@end
