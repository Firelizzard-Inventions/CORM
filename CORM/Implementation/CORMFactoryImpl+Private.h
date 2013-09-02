//
//  CORMFactory_private.h
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//
//  PRIVATE HEADER
//

#import "CORMEntity.h"

@class CORMKey, CORMFactory, CORMEntityImpl;

@interface CORMFactoryImpl (Genesis)

+ (id)factoryForEntity:(Class<CORMEntity>)type fromStore:(CORMStore *)store;
- (id)initWithEntity:(Class<CORMEntity>)type fromStore:(CORMStore *)store;

@end