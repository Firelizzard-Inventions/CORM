//
//  CORMEntity.h
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@protocol CORMEntity <NSObject>

+ (id<CORMEntity>)entity;
+ (id<CORMEntity>)entityForKey:(id)key;
+ (id<CORMEntity>)entityByBindingTo:(id)obj;
- (id)initByBindingTo:(id)obj;

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