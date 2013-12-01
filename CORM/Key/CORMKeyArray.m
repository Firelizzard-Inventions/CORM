//
//  CORMKeyArray.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMKeyArray.h"

#import "CORMKey+Private.h"

@implementation CORMKeyArray {
	NSArray * _backing;
}

+ (instancetype)keyWithArray:(NSArray *)arr
{
	if (!arr)
		return [self keyWithNil];
	
	if (![arr respondsToSelector:@selector(count)] || ![arr respondsToSelector:@selector(objectAtIndexedSubscript:)])
		return [self keyWithNil];
	
	if (!arr.count)
		return [self keyWithNil];
	
	return [[[self alloc] initWithArray:arr] autorelease];
}

- (id)initWithArray:(NSArray *)array;
{
	if (!(self = [super init]))
		return nil;
	
	_backing = [[NSArray alloc] initWithArray:array];
	
	return self;
}

- (NSArray *)values
{
	return _backing;
}

- (void)dealloc
{
	[_backing release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[self.class allocWithZone:zone] initWithArray:_backing];
}

@end