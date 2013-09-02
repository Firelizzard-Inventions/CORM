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

@interface CORMEntityImpl : NSObject <CORMEntity>

+ (void)registerWithDefaultStore;
+ (void)registerWithStore:(CORMStore *)store;
+ (id<CORMFactory>)registeredFactory;

+ (BOOL)propertyNamesAreCaseSensitive;

- (void)invalidate;

@end