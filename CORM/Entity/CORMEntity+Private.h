//
//  CORMEntityImpl_Private.h
//  CORM
//
//  Created by Ethan Reesor on 11/25/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntity.h"

@interface CORMEntity ()

+ (NSArray *)keyNamesForClassName:(NSString *)className;
+ (NSString *)instanceVariableNameForCollectionName:(NSString *)collectionName;

- (BOOL)valid;
- (void)invalidate;

@end