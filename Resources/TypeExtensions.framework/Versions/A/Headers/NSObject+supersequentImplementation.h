//
//  NSObject+supersequentImplementation.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 8/20/13.
//  Copyright (c) 2013 Lens Flare. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@interface NSObject (supersequentImplementation)

#define __supersInvoke(...) \
	([self getImplementationOf:_cmd after:impOfCallingMethod(self, _cmd)]) \
	(self, _cmd, ##__VA_ARGS__)

IMP impOfCallingMethod(id lookupObject, SEL selector);

- (IMP)getImplementationOf:(SEL)lookup after:(IMP)skip;

@end
