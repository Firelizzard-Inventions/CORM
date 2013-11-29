//
//  CORMEntity.h
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

typedef enum {
	kCORMEntityBindingOptionSetReceiverFromObject = 0x01,
	kCORMEntityBindingOptionSetObjectFromReceiver = 0x02
} CORMEntityBindingOption;

@class CORMKey;

@protocol CORMEntity <NSObject>

+ (id<CORMEntity>)unboundEntity;
+ (id<CORMEntity>)entityForKey:(id)key;
+ (id<CORMEntity>)createEntityWithData:(id)data;
+ (NSArray *)findEntitiesForData:(id)data;
+ (NSArray *)findEntitiesWhere:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

- (CORMKey *)key;
- (void)bindTo:(id)object withOptions:(CORMEntityBindingOption)options;

- (void)delete;
+ (void)deleteEntitiesWhere:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

+ (NSString *)mappedClassName;

+ (NSArray *)mappedKeys;
+ (NSArray *)mappedNames;
+ (NSArray *)mappedForeignKeyClassNames;

+ (NSString *)mappedNameForPropertyName:(NSString *)propName;
+ (NSString *)propertyNameForMappedName:(NSString *)mappedName;

+ (NSString *)classNameForForeignKeyPropertyNames:(NSArray *)propNames;
+ (NSArray *)propertyNamesForForeignKeyClassName:(NSString *)className;
+ (NSString *)propertyNameForForeignKeyClassName:(NSString *)className;

+ (BOOL)stringIsMappedKey:(NSString *)string;
+ (BOOL)stringIsMappedName:(NSString *)string;
+ (BOOL)stringIsMappedForeignKeyClassName:(NSString *)string;

+ (BOOL)stringIsKeyProperty:(NSString *)string;
+ (BOOL)stringIsMappedProperty:(NSString *)string;
+ (BOOL)stringIsForeignKeyProperty:(NSString *)string;

@end