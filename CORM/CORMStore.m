//
//  CORMStore.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMStore.h"

#import <ORDA/ORDAGovernor.h>
#import "CORMEntity.h"
#import "CORMFactory.h"
#import "CORMFactory+Private.h"
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

- (CORMFactory *)factoryRegisteredForType:(Class<CORMEntity>)type
{
	return factories[type];
}

- (CORMFactory *)registerFactoryForType:(Class<CORMEntity, NSCopying>)type
{
	CORMFactory * factory = [CORMFactory factoryForEntity:type fromStore:self];
	factories[type] = factory;
	return factory;
}

- (Class<CORMEntity>)generateClassForName:(NSString *)className
{
	NSArray * keys = [self.governor primaryKeyNamesForTableName:className];
	NSArray * columns = [self.governor columnNamesForTableName:className];
	NSArray * foreign = [self.governor foreignKeyTableNamesForTableName:className];
	return [CORMEntityDict entityDictClassWithName:className andKeys:keys andProperties:columns andForeignKeys:foreign];
}

@end
