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
	NSMutableDictionary * data;
}

- (id)valueForKey:(NSString *)key
{
	return data[[CORMKey keyWithObject:key]];
}

- (id)valueForKeyPath:(NSString *)keyPath
{
	return [data valueForKeyPath:keyPath];
}

- (id<CORMEntity>)entityForKey:(id)key
{
	key = [CORMKey keyWithObject:key];
	
	if (data[key])
		return data[key];
	
	id<ORDATableResult> result = [self.table selectWhere:@"%@", [key whereClauseForEntityType:self.type]];
	if (result.isError)
		return nil;
	if (result.count < 1)
		return nil;
	
	NSObject<CORMEntity> * entity = [self.type entityByBindingTo:result[0]];
	
	data[key] = entity;
	return entity;
}

- (id<CORMEntity>)entityOrProxyForKey:(id)key
{
	if (data[key])
		return data[key];
	
	return [CORMEntityProxy entityProxyWithKey:key forFactory:self];
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
	
	data = [[NSMutableDictionary_NonRetaining_Zeroing dictionary] retain];
	
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