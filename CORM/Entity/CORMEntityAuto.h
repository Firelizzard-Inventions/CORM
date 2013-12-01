//
//  CORMEntityBase.h
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityBase.h"

#import <ORDA/ORDA.h>

#define kCORMEntityBadKeysException @"com.firelizzard.CORM.Entity.BadKeysException"
#define kCORMEntityBadClassException @"com.firelizard.CORM.Entity.BadClassException"

@interface CORMEntityAuto : CORMEntityBase

- (void)buildCollections;
- (void)rebuildCollectionForKey:(NSString *)collectionName andView:(id<ORDATableView>)view;

@end

@interface CORMEntityAuto (Synthesize)

+ (void)synthesize;

@end
