//
//  CORMEntity.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntity+Private.h"

#import <TypeExtensions/TypeExtensions.h>

#import "CORMDefaults+Private.h"

@implementation CORMEntity (Registration)

+ (void)registerWithDefaultStore
{
	[self registerWithStore:[CORM defaultStore]];
}

+ (void)registerWithStore:(CORMStore *)store
{
	[(NSObject *)self setAssociatedObject:[store registerFactoryForType:self] forSelector:@selector(registeredFactory)];
}

+ (CORMFactory *)registeredFactory
{
	if (![(NSObject *)self associatedObjectForSelector:_cmd])
		[self registerWithDefaultStore];
	
	return [(NSObject *)self associatedObjectForSelector:_cmd];
}

@end
