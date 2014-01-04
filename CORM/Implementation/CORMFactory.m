//
//  CORMClass.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMFactory+Private.h"

#import <TypeExtensions/TypeExtensions.h>
#import <ORDA/ORDA.h>

#import "CORM.h"
#import "CORMDefaults+Private.h"
#import "CORMEntity.h"
#import "CORMEntityAuto.h"
#import "CORMEntityProxy.h"

@implementation CORMFactory {
	NSMapTable * _data;
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

@implementation CORMFactory (Genesis)

+ (id)factoryForEntity:(Class<CORMMapping>)type fromStore:(CORMStore *)store
{
	return [[[CORMFactory alloc] initWithEntity:type fromStore:store] autorelease];
}

- (id)initWithEntity:(Class<CORMMapping>)type fromStore:(CORMStore *)store
{
	if (!(self = [super init]))
		return nil;
	
	if (![(Class)type isSubclassOfClass:CORMEntity.class])
		return nil;
	
	CORMFactory * existing = [store factoryRegisteredForType:type];
	if (existing)
		return existing;
	
	_type = type;
	_store = store.retain;
	
	_table = [self.store.governor createTable:[self.type mappedClassName]].retain;
	if (!self.table)
		return nil;
	
	_data = [[NSMapTable strongToWeakObjectsMapTable] retain];
	
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

@implementation CORMFactory (EntityGeneration)

#pragma mark Retreive

- (CORMEntity *)entityForKey:(id)key
{
	key = [CORMKey keyWithObject:key];
	
	CORMEntity * entity = _data[key];
	if (entity)
		return entity;
	
	id<ORDATableResult> result = [self.table selectWhere:@"%@", [key whereClauseForEntityType:self.type]];
	if (result.isError)
		return [CORM handleError:result];
	if (result.count < 1)
		return nil;
	
	entity = [(Class)self.type entity];
	
	if (![entity respondsToSelector:@selector(bindTo:withOptions:)])
		return nil;
	
	[entity bindTo:result[0] withOptions:kCORMEntityBindingOptionSetReceiverFromObject];
	
	if ([entity respondsToSelector:@selector(buildCollections)])
		[(CORMEntityAuto *)entity buildCollections];
	
	_data[key] = entity;
	return entity;
}

- (CORMEntity *)entityOrProxyForKey:(id)key
{
	if (_data[key])
		return _data[key];
	
	return (CORMEntity *)[CORMEntityProxy entityProxyWithKey:key forFactory:self];
}

#pragma mark Search

- (NSArray *)findEntitiesForData:(CORMKey *)key
{
	return [self findEntitiesWhere:[key whereClauseForEntityType:self.type]];
}

- (NSArray *)findEntitiesWhere:(NSString *)clause
{
	id<ORDATableResult> results = [self.table selectWhere:@"%@", clause];
	if (results.isError)
		return [CORM handleError:results];
	if (results.count < 1)
		return nil;
	
	NSMutableArray * entities = [NSMutableArray array];
	
	for (id result in results) {
		CORMEntityAuto * entity = [(Class)self.type entity];
		[entity bindTo:result[0] withOptions:kCORMEntityBindingOptionSetReceiverFromObject];
		_data[entity.key] = entity;
		[entities addObject:entity];
	}
	
	return [NSArray arrayWithArray:entities];
}

#pragma mark Create

- (CORMEntity *)createEntityWithData:(id)data
{
	BOOL ignoreCase = NO;
	SUPPRESS(-Wobjc-method-access)
	if ([self.type respondsToSelector:@selector(propertyNamesAreCaseSensitive)])
		ignoreCase = ![self.type propertyNamesAreCaseSensitive];
	UNSUPPRESS()
	
	id<ORDATableResult> result = [self.table insertValues:data ignoreCase:ignoreCase];
	if (result.isError)
		return [CORM handleError:result];
	if (result.count < 1)
		return nil;
	
	CORMEntity * entity = [(Class)self.type entity];
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

#pragma mark View

- (id<ORDATableView>)createViewForKey:(CORMKey *)key
{
	id<ORDATableView> view = [self.table viewWhere:@"%@", [key whereClauseForEntityType:self.type]];
	if (view.isError)
		return [CORM handleError:view];
	return view;
}

@end