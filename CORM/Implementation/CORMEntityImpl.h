//
//  CORMEntity.h
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

#import "CORMEntity.h"

#define kCORMEntityBadKeysException @"com.firelizzard.CORM.Entity.BadKeysException"
#define kCORMEntityBadClassException @"com.firelizard.CORM.Entity.BadClassException"

@protocol CORMFactory;
@class CORMStore;

@interface CORMEntityImpl : NSObject

+ (void)synthesize;
+ (BOOL)propertyNamesAreCaseSensitive;
+ (NSString *)instanceVariableNameForCollectionName:(NSString *)collectionName;

- (void)buildCollections;

@end

@interface CORMEntityImpl (Registration)

+ (void)registerWithDefaultStore;
+ (void)registerWithStore:(CORMStore *)store;
+ (id<CORMFactory>)registeredFactory;

@end

@interface CORMEntityImpl (ConcreteEntity) <CORMEntity>

@end