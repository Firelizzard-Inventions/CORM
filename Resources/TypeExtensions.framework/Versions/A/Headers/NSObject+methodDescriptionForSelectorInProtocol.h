//
//  NSObject+methodDescriptionForSelectorInProtocol.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 8/20/13.
//  Copyright (c) 2013 Lens Flare. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

@interface NSObject (methodDescriptionForSelectorInProtocol)

BOOL isNullMethodDescription(struct objc_method_description description);

+ (struct objc_method_description)methodDescriptionForSelector:(SEL)aSelector inProtocol:(Protocol *)protocol;

@end
