//
//  CORMEntity.h
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CORMEntity <NSObject>

- (id)initWithKey:(id)key;
- (id)initWithKey:(id)key dictionary:(NSDictionary *)dict;

+ (id<CORMEntity>)entityWithKey:(id)key;
+ (id<CORMEntity>)entityWithKey:(id)key dictionary:(NSDictionary *)dict;
+ (id<CORMEntity>)entityForKey:(id)key;


+ (NSString *)mappedClassName;

+ (NSArray *)mappedKeys;
+ (NSArray *)mappedNames;
+ (NSArray *)mappedForeignKeyClassNames;

+ (NSString *)mappedNameForPropertyName:(NSString *)propName;
+ (NSString *)propertyNameForMappedName:(NSString *)mappedName;

+ (NSString *)classNameForForeignKeyPropertyNames:(NSArray *)propNames;
+ (NSArray *)propertyNamesForForeignKeyClassName:(NSString *)className;
+ (NSString *)propertyNameForForeignKeyClassName:(NSString *)className;

@end