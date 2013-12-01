//
//  CORMKey.h
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CORMMapping;

@interface CORMKey : NSObject <NSCopying>

- (NSString *)whereClauseForEntityType:(Class<CORMMapping>)type;

+ (instancetype)key;
+ (instancetype)keyWithNil;
+ (instancetype)keyWithObject:(id)obj;

+ (instancetype)keyWithRowid:(NSNumber *)rowid;
+ (instancetype)keyWithDescriptor:(NSString *)string;

+ (instancetype)keyWithArray:(NSArray *)arr;
+ (instancetype)keyWithObjects:(id)obj, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)keyWithObjects:(const void *)objs count:(NSUInteger)count;

+ (instancetype)keyWithDictionary:(NSDictionary *)dict;
+ (instancetype)keyWithObject:(id)obj forProperty:(NSString *)prop;
+ (instancetype)keyWithObjects:(NSArray *)objs forProperties:(NSArray *)props;
+ (instancetype)keyWithObjectsAndProperties:(id)obj, ... NS_REQUIRES_NIL_TERMINATION;

+ (instancetype)keyWithKey:(CORMKey *)key forEntityType:(Class<CORMMapping>)type;
+ (instancetype)keyWithData:(id)data forEntityType:(Class<CORMMapping>)type;
+ (instancetype)keyWithObjects:(NSArray *)objs forEntityType:(Class<CORMMapping>)type;

@end
