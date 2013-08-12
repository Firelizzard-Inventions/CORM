//
//  CORMFactory_private.h
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//
//  PRIVATE HEADER
//

#import "CORMEntity.h"

@class CORMKey, CORMFactory, CORMEntityImpl;

@interface CORMFactory (Private)

- (id<CORMEntity>)_entityForKey:(CORMKey *)key;

@end

@interface CORMFactory (Genesis)

- (id)initWithEntity:(Class)type fromStore:(CORMStore *)store;

+ (id)factoryForEntity:(Class)type fromStore:(CORMStore *)store;

@end