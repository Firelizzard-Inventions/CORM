//
//  CORMEntity.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntity+Private.h"

#import <TypeExtensions/String.h>

#import "CORMKey.h"
#import "CORMStore.h"
#import "CORMFactory.h"
#import "CORMEntitySynth.h"

@implementation CORMEntity (Observation)

- (void)observeValueForForeignClassName:(NSString *)className propertyNames:(NSArray *)propNames
{
	NSString * prop = [self.class propertyNameForForeignKeyClassName:className];
	
	NSMutableArray * props = [NSMutableArray array];
	for (NSString * propName in propNames) {
		id value = [self valueForKey:propName];
		if (value)
			[props addObject:value];
		else {
			[self setNilValueForKey:prop];
			return;
		}
	}
	
	Class theClass = NSClassFromString(className);
	if (theClass && ![theClass isSubclassOfClass:CORMEntity.class])
		return;
	
	CORMStore * store = [self.class registeredFactory].store;
	if (!theClass && !store.generateClasses)
		return;
	
	if (!theClass)
		if (!(theClass = [CORMEntitySynth synthesizeClassForName:className withStore:self.class.registeredFactory.store]))
			return;
	
	id obj = [[theClass registeredFactory] entityOrProxyForKey:[CORMKey keyWithArray:props]];
	//	if ([[obj class] isSubclassOfClass:CORMEntityProxy.class])
	//		obj = ((CORMEntityProxy *)obj).entity;
	
	[self setValue:obj forKey:prop];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (![self.class.foreignKeyObservationContext isEqual:context])
		return;
	
	for (NSString * className in self.class.mappedForeignKeyClassNames) {
		NSArray * propNames = [self.class propertyNamesForForeignKeyClassName:className];
		for (NSString * propertyName in propNames)
			if ([propertyName isEqualToStringIgnoreCase:keyPath])
				[self observeValueForForeignClassName:className propertyNames:propNames];
	}
}

@end

@implementation _ObservationContext

+ (instancetype)contextWithIdentifier:(id)identifier forContext:(id)context
{
	return [[[self alloc] initWithIdentifier:identifier forContext:context] autorelease];
}

- (id)initWithIdentifier:(id)identifier forContext:(id)context
{
	if (!(self = [super init]))
		return nil;
	
	_identifier = [identifier retain];
	_context = [context retain];
	
	return self;
}

- (BOOL)isEqual:(id)object
{
	if (!object)
		return NO;
	
	if (object == self)
		return YES;
	
	if (![object isKindOfClass:_ObservationContext.class])
		return NO;
	
	_ObservationContext * other = (_ObservationContext *)object;
	
	if (!self.identifier)
		if (other.identifier)
			return NO;
	if (![self.identifier isEqual:other.identifier])
		return NO;
	
	if (!self.context)
		if (other.context)
			return NO;
	if (![self.context isEqual:other.context])
		return NO;
	
	return YES;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ - %@>", self.identifier, self.context];
}

@end















