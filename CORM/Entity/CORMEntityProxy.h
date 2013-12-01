//
//  CORMEntityProxy.h
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

@class CORMKey, CORMEntity, CORMFactory;

@interface CORMEntityProxy : NSProxy

@property (readonly) CORMKey * key;
@property (readonly) CORMFactory * factory;
@property (readonly) CORMEntity * entity;

+ (CORMEntityProxy *)entityProxyWithKey:(id)key forFactory:(CORMFactory *)factory;
- (id)initWithKey:(id)key forFactory:(CORMFactory *)factory;

@end
