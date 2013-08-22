//
//  CORMKey.h
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@protocol CORMEntity;

@interface CORMKey : NSArray

- (NSString *)whereClauseForEntityType:(Class<CORMEntity>)type;

@end

@interface CORMKey (Genesis)

+ (id)key;
+ (id)keyWithDescriptor:(NSString *)string;
+ (id)keyWithObject:(id)obj;
+ (id)keyWithArray:(NSArray *)arr;
+ (id)keyWithObjects:(id)obj, ... NS_REQUIRES_NIL_TERMINATION;
+ (id)keyWithObjects:(const void *)objs count:(NSUInteger)count;

@end