//
//  NSString+characterAtIndexSubscript.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Lens Flare. Some rights reserved, see license.
//

#import <Foundation/NSString.h>

@interface NSString (characterAtIndexSubscript)

- (NSNumber *)objectAtIndexedSubscript:(NSUInteger)idx;

@end
