//
//  CORMEntityProxy.h
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//
//  PRIVATE HEADER
//

#import <Foundation/Foundation.h>

#import "CORMEntity.h"

@class CORMKey, CORMFactory, CORMEntityImpl;

@interface CORMEntityProxy : NSProxy <CORMEntity>

@property (readonly) CORMKey * key;
@property (readonly) CORMFactory * factory;
@property (readonly) CORMEntityImpl * entity;

+ (CORMEntityProxy *)entityProxyWithKey:(CORMKey *)key forFactory:(CORMFactory *)factory;
- (id)initWithKey:(CORMKey *)key forFactory:(CORMFactory *)factory;

@end
