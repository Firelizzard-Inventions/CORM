//
//  CORM.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORM.h"

#import "CORMStore.h"

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

@end
