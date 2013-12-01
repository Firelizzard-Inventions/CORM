//
//  CORM.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMDefaults.h"
#import "CORMDefaults+Private.h"

#import <ORDA/ORDA.h>

#import "CORM.h"

@implementation CORM

static CORMStore * _defaultStore = nil;

+ (CORMStore *)defaultStore
{
	return _defaultStore;
}

+ (void)setDefaultStore:(CORMStore *)store
{
	[_defaultStore release];
	_defaultStore = store.retain;
}

+ (id)handleError:(id<ORDAResult>)errorResult
{
	[NSException raise:@"ORDA Exception" format:@"%@", [ORDA descriptionForCode:errorResult.code]];
	return nil;
}

@end
