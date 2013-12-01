//
//  CORMClass.h
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

#import <ORDA/ORDA.h>

@protocol CORMMapping;
@class CORMStore, CORMEntity, CORMKey;

@interface CORMFactory : NSObject

@property (readonly) Class<CORMMapping> type;
@property (readonly) id<ORDATable> table;
@property (readonly) CORMStore * store;

@end

@interface CORMFactory (EntityGeneration)

- (CORMEntity *)entityForKey:(id)key;
- (CORMEntity *)entityOrProxyForKey:(id)key;

- (NSArray *)findEntitiesForData:(CORMKey *)key;
- (NSArray *)findEntitiesWhere:(NSString *)clause;

- (CORMEntity *)createEntityWithData:(id)data;

- (void)deleteEntityForKey:(CORMKey *)key;
- (void)deleteEntitiesWhere:(NSString *)clause;

- (id<ORDATableView>)createViewForKey:(CORMKey *)key;

@end