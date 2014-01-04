//
//  NSString+isEqualToStringIgnoreCase.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 8/22/13.
//  Copyright (c) 2013 Lens Flare. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@interface NSString (isEqualToStringIgnoreCase)

- (BOOL)isEqualToStringIgnoreCase:(NSString *)aString;
- (BOOL)isEqualToString:(NSString *)aString ignoreCase:(BOOL)i;

@end
