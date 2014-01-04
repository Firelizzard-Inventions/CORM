//
//  NSObject+invocationForSelector.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 11/25/12.
//  Copyright (c) 2012 Lens Flare. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@interface NSObject (invocationForSelector)

- (NSInvocation *)invocationForSelector:(SEL)selector;

@end
