//
//  CORMClass.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMFactory.h"
#import "CORMFactory+Private.h"

#import <ORDA/ORDAGovernor.h>
#import <ORDA/ORDAStatement.h>
#import <ORDA/ORDAStatementResult.h>
#import "CORMStore.h"
#import "CORMKey.h"
#import "CORMEntity.h"
#import "CORMEntityProxy.h"

@implementation CORMFactory {
	NSMutableDictionary * data;
}

- (id)valueForKey:(NSString *)key
{
	return [data valueForKey:key];
}

- (id)valueForKeyPath:(NSString *)keyPath
{
	return [data valueForKeyPath:keyPath];
}

@end

@implementation CORMFactory (Private)

- (id<CORMEntity>)entityForKey:(CORMKey *)key
{
	if (data[key])
		return data[key];
	
	id<ORDATableResult> result = [self.table selectWhere:[key whereClauseForEntityType:self.type]];
	if (result.isError)
		return nil;
	if (result.count < 1)
		return nil;
	
	NSObject<CORMEntity> * entity = [self.type entityByBindingTo:result[0]];
	
	data[key] = entity;
	return entity;
}

- (id<CORMEntity>)entityOrProxyForKey:(CORMKey *)key
{
	if (data[key])
		return data[key];
	
	return [CORMEntityProxy entityProxyWithKey:key forFactory:self];
}

@end

@implementation CORMFactory (Genesis)

+ (id)factoryForEntity:(Class)type fromStore:(CORMStore *)store
{
	return [[[CORMFactory alloc] initWithEntity:type fromStore:store] autorelease];
}

- (id)initWithEntity:(Class<CORMEntity>)type fromStore:(CORMStore *)store
{
	if (!(self = [super init]))
		return nil;
	
	if (![((Class)type) conformsToProtocol:@protocol(CORMEntity)])
		return nil;
	
	CORMFactory * existing = [store factoryRegisteredForType:type];
	if (existing)
		return existing;
	
	_type = type;
	_store = store.retain;
	
	_table = [self.store.governor createTable:[self.type mappedClassName]].retain;
	if (!self.table)
		return nil;
	
	data = @{}.mutableCopy;
	
	return self;
}

- (void)dealloc
{
	[data release];
	[_table release];
	[_store release];
	
	[super dealloc];
}

@end