//
//  NSNull+nullForProtocol.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 8/20/13.
//  Copyright (c) 2013 Lens Flare. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@interface NSNull (nullForProtocol)

+ (id)nullForProtocol:(Protocol *)protocol;

@end
