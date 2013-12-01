//
//  CORMEntity.h
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kCORMEntityBindingOptionSetReceiverFromObject = 0x01,
	kCORMEntityBindingOptionSetObjectFromReceiver = 0x02
} CORMEntityBindingOption;

@class CORMKey, CORMStore, CORMFactory;

@interface CORMEntity : NSObject

- (CORMKey *)key;

@end

@interface CORMEntity (Binding)

- (void)bindTo:(id)object withOptions:(CORMEntityBindingOption)options;

@end

@interface CORMEntity (Relational)

- (void)delete;

+ (instancetype)entity;
+ (instancetype)entityForKey:(id)key;
+ (instancetype)entityProxyForKey:(id)key;
+ (instancetype)entitySynthForName:(NSString *)className andKey:(id)key;

+ (instancetype)createEntityWithData:(id)data;

+ (NSArray *)findEntitiesForData:(id)data;
+ (NSArray *)findEntitiesWhere:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

+ (void)deleteEntitiesWhere:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end

@protocol CORMMapping <NSObject>

/** ----------------------------------------------------------------------------
 * @name Mapped Data Accesors
 */

+ (NSString *)mappedClassName;

+ (NSArray *)mappedKeys;
+ (NSArray *)mappedNames;
+ (NSArray *)mappedForeignKeyClassNames;

+ (NSArray *)referencingClassNames;

/** ----------------------------------------------------------------------------
 * @name Object/Relational Data Mapping
 */

+ (NSString *)mappedNameForPropertyName:(NSString *)propName;
+ (NSString *)propertyNameForMappedName:(NSString *)mappedName;

+ (NSString *)classNameForForeignKeyPropertyNames:(NSArray *)propNames;
+ (NSArray *)propertyNamesForForeignKeyClassName:(NSString *)className;

+ (NSString *)classNameForForeignKeyPropertyName:(NSString *)propName;
+ (NSString *)propertyNameForForeignKeyClassName:(NSString *)className;

+ (NSString *)referencingClassNameForCollectionName:(NSString *)collectionName;
+ (NSString *)collectionNameForReferencingClassName:(NSString *)className;

/** ----------------------------------------------------------------------------
 * @name Tests
 */

+ (BOOL)stringIsMappedKey:(NSString *)string;
+ (BOOL)stringIsMappedName:(NSString *)string;
+ (BOOL)stringIsMappedForeignKeyClassName:(NSString *)string;
+ (BOOL)stringIsReferencingClassName:(NSString *)string;

+ (BOOL)stringIsKeyProperty:(NSString *)string;
+ (BOOL)stringIsMappedProperty:(NSString *)string;
+ (BOOL)stringIsForeignKeyProperty:(NSString *)string;
+ (BOOL)stringIsCollectionProperty:(NSString *)string;

@end

@interface CORMEntity (Mapping) <CORMMapping>

@end

@interface CORMEntity (Registration)

+ (void)registerWithDefaultStore;
+ (void)registerWithStore:(CORMStore *)store;
+ (CORMFactory *)registeredFactory;

@end