//
//  CORMClass.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMFactory.h"
#import "CORMFactory_private.h"

#import "CORMStore.h"
#import "CORMKey.h"
#import "CORMEntityImpl.h"

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

- (id)objectForKeyedSubscript:(id)key
{
	return data[[CORMKey keyWithObject:key]];
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
	// get data
	NSDictionary * dict = nil;
	
	id<CORMEntity> entity = [self.type entityWithKey:key];
	for (NSString * key in dict) {
		NSString * prop = [self.type propertyNameForMappedName:key];
//		[entity setv];
	}
	
	data[key] = entity;
	return entity;
}

@end

@implementation CORMFactory (Genesis)

- (id)initWithEntity:(Class)type fromStore:(CORMStore *)store
{
	if (!(self = [super init]))
		return nil;
	
	if (![type isSubclassOfClass:[CORMEntityImpl class]])
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