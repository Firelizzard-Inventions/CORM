//
//  CORMEntity.h
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CORMEntity.h"

#define kCORMEntityBadKeysException @"com.firelizzard.CORM.Entity.BadKeysException"

@class CORMFactory, CORMStore;

@interface CORMEntityImpl : NSObject <CORMEntity>

+ (CORMFactory *)registerWithStore:(CORMStore *)store;
+ (CORMFactory *)setDefaultStore:(CORMStore *)store;
+ (CORMFactory *)defaultFactory;
+ (void)setDefaultFactory:(CORMFactory *)newFactory;

@end