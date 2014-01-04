//
//  NSMapTable+objectForKeyedSubscript.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 1/2/14.
//  Copyright (c) 2014 Lens Flare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMapTable (objectForKeyedSubscript)

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id)key;

@end
