//
//  PRIVATE_NSObject_KVCArrayForwarding.h
//  TypeExtensions
//
//  Created by Ethan Reesor on 2/17/13.
//  Copyright (c) 2013 Lens Flare. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@interface NSObject_KVCArrayForwarding : NSObject

- (id)initWithTarget:(id)theTarget keyPath:(NSString *)theKeyPath isMutable:(BOOL)isMutable;

@end
