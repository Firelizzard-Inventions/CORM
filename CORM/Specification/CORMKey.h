//
//  CORMKey.h
//  CORM
//
//  Created by Ethan Reesor on 11/30/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CORMEntity;

@protocol CORMKey <NSObject>

- (NSString *)whereClauseForEntityType:(Class<CORMEntity>)type;

+ (id<CORMKey>)key;
+ (id<CORMKey>)keyWithRowid:(NSNumber *)rowid;
+ (id<CORMKey>)keyWithDescriptor:(NSString *)string;
+ (id<CORMKey>)keyWithObject:(id)obj;
+ (id<CORMKey>)keyWithArray:(NSArray *)arr;
+ (id<CORMKey>)keyWithObjects:(id)obj, ... NS_REQUIRES_NIL_TERMINATION;
+ (id<CORMKey>)keyWithObjects:(const void *)objs count:(NSUInteger)count;

@end
