//
//  NSObject+invokeSafely.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 11/20/13.
//  Copyright (c) 2013 Lens Flare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (invokeSafely)

+ (void)invokeSafely:(NSInvocation *)invocation;

@end
