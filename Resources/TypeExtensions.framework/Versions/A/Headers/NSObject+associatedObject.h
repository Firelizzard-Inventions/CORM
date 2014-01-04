//
//  NSObject+associatedObjectForSelector.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 8/22/13.
//  Copyright (c) 2013 Lens Flare. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@interface NSObject (associatedObject)

- (id)associatedObjectForKey:(const char *)key;
- (void)setAssociatedObject:(id)obj forKey:(const char *)key;

- (id)associatedObjectForSelector:(SEL)aSelector;
- (void)setAssociatedObject:(id)obj forSelector:(SEL)aSelector;

- (id)associatedObjectForClass:(Class)aClass;
- (id)associatedObjectForClass;
- (void)setAssociatedObject:(id)obj forClass:(Class)aClass;
- (void)setAssociatedObjectForClass:(id)obj;

@end
