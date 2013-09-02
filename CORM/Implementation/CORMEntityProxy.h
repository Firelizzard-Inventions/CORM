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

@protocol CORMFactory;
@class CORMKey, CORMEntityImpl;

@interface CORMEntityProxy : NSProxy <CORMEntity>

@property (readonly) CORMKey * key;
@property (readonly) id<CORMFactory> factory;
@property (readonly) CORMEntityImpl * entity;

+ (CORMEntityProxy *)entityProxyWithKey:(id)key forFactory:(id<CORMFactory>)factory;
- (id)initWithKey:(id)key forFactory:(id<CORMFactory>)factory;

@end
