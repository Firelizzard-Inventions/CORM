//
//  CORMClass.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
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

- (void)dealloc
{
	[data release];
	[super dealloc];
}

@end

@implementation CORMFactory (Private)

- (id<CORMEntity>)_entityForKey:(CORMKey *)key
{
	if (data[key])
		return data[key];
	
	NSString * stmtstr = [NSString stringWithFormat:@"SELECT * FROM [%@] WHERE %@", [self.type mappedClassName], [key whereClauseForEntityType:self.type]];
	id<ORDAStatement> stmt = [self.store.governor createStatement:stmtstr];
	if (stmt.isError)
		return nil;
	
	id <ORDAStatementResult> result = stmt.result;
	if (result.isError)
		return nil;
	if (result.rows < 1)
		return nil;
	
	NSDictionary * dict = result[0];
	
	NSObject<CORMEntity> * entity = [self.type entityWithKey:key];
	for (NSString * columnName in dict)
		[entity setValue:dict[columnName] forKey:[self.type propertyNameForMappedName:columnName]];
	
	for (NSString * className in [self.type mappedForeignKeyClassNames]) {
		Class theClass = NSClassFromString(className);
		
		if (theClass && ![theClass conformsToProtocol:@protocol(CORMEntity)])
			continue;
		
		if (!theClass && !self.store.generateClasses)
			continue;
		
		if (!theClass)
			theClass = [self.store generateClassForName:className];
		
		if (!theClass)
			continue;
		
		NSMutableArray * props = [NSMutableArray array];
		for (NSString * propName in [self.type propertyNamesForForeignKeyClassName:className])
			[props addObject:[entity valueForKey:propName]];
		
		id proxy = [CORMEntityProxy entityProxyWithKey:[CORMKey keyWithArray:props] forFactory:[self.store factoryRegisteredForType:theClass]];
		NSString * prop = [self.type propertyNameForForeignKeyClassName:className];
		[entity setValue:proxy forKey:prop];
	}
	
	data[key] = entity;
	return entity;
}

@end

@implementation CORMFactory (Genesis)

- (id)initWithEntity:(Class<CORMEntity>)type fromStore:(CORMStore *)store
{
	if (!(self = [super init]))
		return nil;
	
	if (![((Class)type) conformsToProtocol:@protocol(CORMEntity)])
		return nil;
	
	CORMFactory * existing = [store factoryRegisteredForType:type];
	if (existing)
		return existing;
	
	data = @{}.mutableCopy;
	_type = type;
	_store = store;
	
	return self;
}

+ (id)factoryForEntity:(Class)type fromStore:(CORMStore *)store
{
	return [[[CORMFactory alloc] initWithEntity:type fromStore:store] autorelease];
}

@end