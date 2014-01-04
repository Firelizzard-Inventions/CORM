//
//  NSDictionary+entrySet.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 12/9/12.
//  Copyright (c) 2012 Lens Flare. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (entrySet)

- (NSSet *)entrySet;

@end

@protocol NSDictionaryEntry <NSObject>

- (id<NSObject>)key;
- (id<NSObject>)object;

@end