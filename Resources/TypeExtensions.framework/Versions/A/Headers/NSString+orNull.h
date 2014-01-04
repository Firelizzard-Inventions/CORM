//
//  NSString+orNull.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 2/8/13.
//  Copyright (c) 2013 Lens Flare. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@interface NSString (orNull)

+ (id)stringWithCStringOrNil:(const char *)cString encoding:(NSStringEncoding)enc;

@end
