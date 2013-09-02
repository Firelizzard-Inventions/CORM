//
//  CORMStore.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMStore.h"

#import <ORDA/ORDA.h>
#import "CORMEntity.h"
#import "CORMFactoryImpl.h"
#import "CORMFactoryImpl+Private.h"
#import "CORMEntityDict.h"

@implementation CORMStore {
	NSMutableDictionary * factories;
}

- (id)initWithGovernor:(id<ORDAGovernor>)governor
{
	if (!(self = [super init]))
		return nil;
	
	_governor = governor.retain;
	factories = @{}.mutableCopy;
	
	return self;
}

- (void)dealloc
{
	[_governor release];
	[factories release];
	
	[super dealloc];
}

- (id<CORMFactory>)factoryRegisteredForType:(Class<CORMEntity>)type
{
	return factories[[type mappedClassName]];
}

- (id<CORMFactory>)registerFactoryForType:(Class<CORMEntity, NSCopying>)type
{
	CORMFactoryImpl * factory = factories[[type mappedClassName]];
	if (factory)
		return factory;
	
	factory = [CORMFactoryImpl factoryForEntity:type fromStore:self];
	factories[[type mappedClassName]] = factory;
	return factory;
}

- (Class<CORMEntity>)generateClassForName:(NSString *)className
{
	Class aClass = NSClassFromString(className);
	if (aClass) {
		if ([aClass conformsToProtocol:@protocol(CORMEntity)])
			return aClass;
		else
			return nil;
	}
	
	id<ORDATable> table = [self.governor createTable:className];
	if (table.isError)
		return nil;
	
	NSArray * keys = [table primaryKeyNames];
	NSArray * columns = [table columnNames];
	NSArray * foreign = [table foreignKeyTableNames];
	return [CORMEntityDict entityDictClassWithName:className andKeys:keys andProperties:columns andForeignKeys:foreign];
}

@end
