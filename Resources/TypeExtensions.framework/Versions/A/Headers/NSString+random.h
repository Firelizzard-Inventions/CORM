//
//  NSString+randomString.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 8/24/13.
//  Copyright (c) 2013 Lens Flare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (random)

- (NSString *)stringWithNumberOfRandomCharactersFromString:(NSUInteger)count;

@end
