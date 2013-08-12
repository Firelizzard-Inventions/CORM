//
//  CORMEntityProxy.h
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
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

- (id)initWithKey:(CORMKey *)key forFactory:(CORMFactory *)factory;

@end
