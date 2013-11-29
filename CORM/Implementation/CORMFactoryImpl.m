//
//  CORMClass.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMFactoryImpl.h"
#import "CORMFactoryImpl+Private.h"

#import <ORDA/ORDAGovernor.h>
#import <ORDA/ORDAStatement.h>
#import <ORDA/ORDAStatementResult.h>

#import <TypeExtensions/NSMutableDictionary_NonRetaining_Zeroing.h>

#import "CORMStore.h"
#import "CORMFactory.h"
#import "CORMKey.h"
#import "CORMEntity.h"
#import "CORMEntityProxy.h"

@implementation CORMFactoryImpl {
	NSMutableDictionary * _data;
}

- (id)valueForKey:(NSString *)key
{
	return _data[[CORMKey keyWithObject:key]];
}

- (id)valueForKeyPath:(NSString *)keyPath
{
	return [_data valueForKeyPath:keyPath];
}

@end

@implementation CORMFactoryImpl (Genesis)

+ (id)factoryForEntity:(Class)type fromStore:(CORMStore *)store
{
	return [[[CORMFactoryImpl alloc] initWithEntity:type fromStore:store] autorelease];
}

- (id)initWithEntity:(Class<CORMEntity>)type fromStore:(CORMStore *)store
{
	if (!(self = [super init]))
		return nil;
	
	if (![((Class)type) conformsToProtocol:@protocol(CORMEntity)])
		return nil;
	
	id<CORMFactory> existing = [store factoryRegisteredForType:type];
	if (existing)
		return existing;
	
	_type = type;
	_store = store.retain;
	
	_table = [self.store.governor createTable:[self.type mappedClassName]].retain;
	if (!self.table)
		return nil;
	
	_data = [[NSMutableDictionary_NonRetaining_Zeroing dictionary] retain];
	
	return self;
}

- (void)dealloc
{
	[_data release];
	[_table release];
	[_store release];
	
	[super dealloc];
}

@end

@implementation CORMFactoryImpl (ConcreteFactory)

#pragma mark Retreive

- (id<CORMEntity>)entityForKey:(id)key
{
	key = [CORMKey keyWithObject:key];
	
	if (_data[key])
		return _data[key];
	
	id<ORDATableResult> result = [self.table selectWhere:@"%@", [key whereClauseForEntityType:self.type]];
	if (result.isError)
		return nil;
	if (result.count < 1)
		return nil;
	
	NSObject<CORMEntity> * entity = [self.type unboundEntity];
	[entity bindTo:result[0] withOptions:kCORMEntityBindingOptionSetReceiverFromObject];
	
	_data[key] = entity;
	return entity;
}

- (id<CORMEntity>)entityOrProxyForKey:(id)key
{
	if (_data[key])
		return _data[key];
	
	return [CORMEntityProxy entityProxyWithKey:key forFactory:self];
}

#pragma mark Search

- (NSArray *)findEntitiesForData:(id)data
{
	NSMutableArray * clauses = [NSMutableArray array];
	
	if ([data respondsToSelector:@selector(allKeys)]) {
		for (NSString * name in [_data allKeys])
			[clauses addObject:[NSString stringWithFormat:@"[%@] = '%@'", [self.type mappedNameForPropertyName:name], [_data valueForKey:name]]];
	} else {
		for (NSString * name in [self.type mappedNames])
			[clauses addObject:[NSString stringWithFormat:@"[%@] = '%@'", name, [_data valueForKey:[self.type propertyNameForMappedName:name]]]];
	}
	
	BOOL ignoreCase = NO;
	SUPPRESS(-Wobjc-method-access)
	if ([self.type respondsToSelector:@selector(propertyNamesAreCaseSensitive)])
		ignoreCase = ![self.type propertyNamesAreCaseSensitive];
	UNSUPPRESS()
	
	return [self findEntitiesWhere:[clauses componentsJoinedByString:@" AND "]];
}

- (NSArray *)findEntitiesWhere:(NSString *)clause
{
	id<ORDATableResult> results = [self.table selectWhere:@"%@", clause];
	if (results.isError)
		return nil;
	if (results.count < 1)
		return nil;
	
	NSMutableArray * entities = [NSMutableArray array];
	
	for (id result in results) {
		id<CORMEntity> entity = [self.type unboundEntity];
		[entity bindTo:result[0] withOptions:kCORMEntityBindingOptionSetReceiverFromObject];
		_data[entity.key] = entity;
		[entities addObject:entity];
	}
	
	return [NSArray arrayWithArray:entities];
}

#pragma mark Create

- (id<CORMEntity>)createEntityWithData:(id)data
{
	BOOL ignoreCase = NO;
	SUPPRESS(-Wobjc-method-access)
	if ([self.type respondsToSelector:@selector(propertyNamesAreCaseSensitive)])
		ignoreCase = ![self.type propertyNamesAreCaseSensitive];
	UNSUPPRESS()
	
	id<ORDATableResult> result = [self.table insertValues:data ignoreCase:ignoreCase];
	if (result.isError)
		return nil;
	if (result.count < 1)
		return nil;
	
	id<CORMEntity> entity = [self.type unboundEntity];
	[entity bindTo:result[0] withOptions:kCORMEntityBindingOptionSetReceiverFromObject];
	
	_data[entity.key] = entity;
	return entity;
}

#pragma mark Delete

- (void)deleteEntityForKey:(CORMKey *)key
{
	[self deleteEntitiesWhere:[key whereClauseForEntityType:self.type]];
}

- (void)deleteEntitiesWhere:(NSString *)clause
{
	[self.table deleteWhere:@"%@", clause];
}

@end