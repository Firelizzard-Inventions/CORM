//
//  CORMEntity.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntity+Private.h"

#import "CORMFactory.h"
#import "CORMEntityAuto.h"
#import "CORMEntitySynth.h"

@implementation CORMEntity (Relational)

- (void)delete
{
	[self.class.registeredFactory deleteEntityForKey:self.key];
}

+ (instancetype)entity
{
	return [[[self alloc] init] autorelease];
}

+ (instancetype)entityForKey:(id)key
{
	return [self.registeredFactory entityForKey:key];
}

+ (instancetype)entityProxyForKey:(id)key
{
	return [self.registeredFactory entityOrProxyForKey:key];
}

+ (instancetype)entitySynthForName:(NSString *)className andKey:(id)key
{
	return [[CORMEntitySynth synthesizeClassForName:className withStore:self.registeredFactory.store] entityForKey:key];
}

+ (instancetype)createEntityWithData:(id)data
{
	return [self.registeredFactory createEntityWithData:data];
}

+ (NSArray *)findEntitiesForData:(id)data
{
	return [self.registeredFactory findEntitiesForData:data];
}

+ (NSArray *)findEntitiesWhere:(NSString *)format, ...
{
	NSString * clause;
	VARGS_STRING(format, clause);
	
	return [self.registeredFactory findEntitiesWhere:clause];
}

+ (void)deleteEntitiesWhere:(NSString *)format, ...
{
	NSString * clause;
	VARGS_STRING(format, clause);
	
	[self.registeredFactory deleteEntitiesWhere:clause];
}

@end
