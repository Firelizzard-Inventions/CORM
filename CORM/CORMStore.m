//
//  CORMStore.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMStore.h"

#import "CORMFactory.h"
#import "CORMFactory_private.h"

@implementation CORMStore {
	NSMutableDictionary * factories;
}

- (id)initWithTHigns
{
	if (!(self = [super init]))
		return nil;
	
	factories = @{}.mutableCopy;
	
	return self;
}

- (void)dealloc
{
	[factories release];
	[super dealloc];
}

- (CORMFactory *)factoryRegisteredForType:(Class)class
{
	return factories[class];
}

- (CORMFactory *)registerFactoryForType:(Class<NSCopying>)class
{
	CORMFactory * factory = [CORMFactory factoryForEntity:class fromStore:self];
	factories[class] = factory;
	return factory;
}

@end
