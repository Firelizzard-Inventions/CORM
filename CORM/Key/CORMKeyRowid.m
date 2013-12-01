//
//  CORMKeyRowid.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMKeyRowid.h"

#import "CORMKey+Private.h"

@implementation CORMKeyRowid

+ (instancetype)keyWithRowid:(NSNumber *)rowid
{
	return [[[self alloc] initWithRowid:rowid] autorelease];
}

- (id)initWithRowid:(NSNumber *)rowid
{
	if (!(self = [super init]))
		return nil;
	
	_rowid = rowid.retain;
	
	return self;
}

- (void)dealloc
{
	[_rowid release];
	
	[super dealloc];
}

- (NSArray *)propertiesForEntityType:(Class<CORMMapping>)type
{
	return @[@"rowid"];
}

- (NSArray *)values
{
	return @[self.rowid];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[self.class allocWithZone:zone] initWithRowid:self.rowid];
}

@end