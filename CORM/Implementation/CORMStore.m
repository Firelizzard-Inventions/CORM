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
#import "CORMFactory+Private.h"

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

- (CORMFactory *)factoryRegisteredForType:(Class)type
{
	return factories[[type mappedClassName]];
}

- (CORMFactory *)registerFactoryForType:(Class<NSCopying, CORMMapping>)type
{
	CORMFactory * factory = factories[[type mappedClassName]];
	if (factory)
		return factory;
	
	factory = [CORMFactory factoryForEntity:type fromStore:self];
	factories[[type mappedClassName]] = factory;
	return factory;
}



@end
