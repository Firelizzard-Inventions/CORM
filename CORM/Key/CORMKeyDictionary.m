//
//  CORMKeyDictionary.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMKeyDictionary.h"

#import "CORMKey+Private.h"

@implementation CORMKeyDictionary {
	NSDictionary * _backing;
}

+ (instancetype)keyWithDictionary:(NSDictionary *)dict
{
	if (!dict)
		return [self keyWithNil];
	
	if (![dict respondsToSelector:@selector(count)] || ![dict respondsToSelector:@selector(objectForKeyedSubscript:)])
		return [self keyWithNil];
	
	if (!dict.count)
		return [self keyWithNil];
	
	return [[[self alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	if (!(self = [super init]))
		return nil;
	
	_backing = [[NSDictionary alloc] initWithDictionary:dictionary];
	
	return self;
}

- (NSArray *)propertiesForEntityType:(Class<CORMMapping>)type
{
	return _backing.allKeys;
}

- (NSArray *)values
{
	return _backing.allValues;
}

- (void)dealloc
{
	[_backing release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[self.class allocWithZone:zone] initWithDictionary:_backing];
}

@end
