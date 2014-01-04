//
//  ORDAErrorResult.h
//  ORDA
//
//  Created by Ethan Reesor on 8/20/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <TypeExtensions/TypeExtensions.h>

#import "ORDAResult.h"

/**
 * ORDAErrorResult is an implementation of ORDAResult that is used to return
 * error codes.
 */
@interface ORDAErrorResult : NSObject_ProtocolConformer <ORDAResult>

@property (readonly) ORDAResultCode code;

+ (ORDAErrorResult *)errorWithCode:(ORDAResultCode)code andProtocol:(Protocol *)protocol;
- (id)initWithCode:(ORDAResultCode)code andProtocol:(Protocol *)protocol;

@end
