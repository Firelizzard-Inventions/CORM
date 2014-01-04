//
//  ORDATableImpl.h
//  ORDA
//
//  Created by Ethan Reesor on 8/24/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "ORDAResultImpl.h"

#import "ORDATable.h"

@protocol ORDAGovernor;

/**
 * ORDATableImpl is a partial implementation of ORDATable. Subclasses of
 * ORDATableImpl must insure that only instances conforming to
 * ORDATableResutlEntry are added to the rows dictionary.
 */
@interface ORDATableImpl : ORDAResultImpl <ORDATable>

@property (readonly) NSString * name;
@property (readonly) id<ORDAGovernor> governor;
@property (readonly) NSMapTable * rows, * views;

+ (ORDATableImpl *)tableWithGovernor:(id<ORDAGovernor>)governor withName:(NSString *)tableName;
- (id)initWithGovernor:(id<ORDAGovernor>)governor withName:(NSString *)tableName;

- (id)keyForTableUpdate:(ORDATableUpdateType)type toRowWithKey:(id)key;

- (NSUInteger)nextViewID;

@end

@protocol ORDATableResultEntry <NSObject>

- (void)update;

@end
