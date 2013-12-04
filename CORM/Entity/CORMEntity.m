//
//  CORMEntity.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntity+Private.h"

#import <TypeExtensions/TypeExtensions.h>
#import <TypeExtensions/String.h>

@implementation CORMEntity {
	BOOL _valid;
}

+ (id)foreignKeyObservationContext
{
	static id _ctxt = nil;
	
	if (!_ctxt)
		_ctxt = [[_ObservationContext contextWithIdentifier:@"com.firelizzard.CORM.observe.entity.foreignKey" forContext:CORMEntity.class] retain];
	
	return _ctxt;
}

#pragma mark Lifecycle

- (id)init
{
	if (!(self = [super init]))
		return nil;
	
	if (self.class == CORMEntity.class)
		@throw [NSException exceptionWithName:@"Abstract class instantiation" reason:@"CORMEntity cannot be directly instantiated - it is the abstract class base of a class cluster" userInfo:nil];
	
	_valid = YES;
	
	for (NSString * className in self.class.mappedForeignKeyClassNames)
		for (NSString * propName in [self.class propertyNamesForForeignKeyClassName:className]) {
			NSLog(@"%@: %@", className, propName);
			[self addObserver:self forKeyPath:propName options:0 context:self.class.foreignKeyObservationContext];
		}
	
	return self;
}

- (void)invalidate
{
	if (!self.valid)
		return;
	
	for (NSString * mappedName in self.class.mappedNames)
		[self setValue:nil forKey:[self.class propertyNameForMappedName:mappedName]];
	
	for (NSString * className in self.class.mappedForeignKeyClassNames)
		for (NSString * propName in [self.class propertyNamesForForeignKeyClassName:className])
			[self removeObserver:self forKeyPath:propName context:self.class.foreignKeyObservationContext];
	
	_valid = NO;
}

- (void)dealloc
{
	[self invalidate];
	
	[super dealloc];
}

#pragma mark Properties

- (CORMKey *)key
{
	return nil;
}

- (BOOL)valid
{
	return _valid;
}

- (NSString *)description
{
	NSArray * mappedNames = [self.class mappedNames];
	NSArray * keyNames = [self.class mappedKeys];
	NSMutableArray * props = [NSMutableArray array];
	
	for (NSString * keyName in keyNames) {
		NSString * prop = [self.class propertyNameForMappedName:keyName];
		[props addObject:[NSString stringWithFormat:@"{%@}='%@'", prop, [self valueForKey:prop]]];
	}
	
	for (NSString * mappedName in mappedNames)
		if (![keyNames containsObject:mappedName]) {
			NSString * prop = [self.class propertyNameForMappedName:mappedName];
			[props addObject:[NSString stringWithFormat:@"[%@]='%@'", prop, [self valueForKey:prop]]];
		}
	
	return [NSString stringWithFormat:@"<%@: %@>", [self className], [props componentsJoinedByString:@", "]];
}

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone
{
	CORMEntity * copy = [[self.class alloc] init];
	
	for (NSString * mappedName in self.class.mappedNames) {
		NSString * prop = [self.class propertyNameForMappedName:mappedName];
		[copy setValue:[self valueForKey:prop] forKey:prop];
	}
	
	//	for (NSString * className in [self.class mappedForeignKeyClassNames])
	//		for (NSString * propName in [self.class propertyNamesForForeignKeyClassName:className])
	//			[copy setValue:[self valueForKey:propName] forKey:propName];
	//
	//	for (NSString * className in self.class.referencingClassNames) {
	//		NSString * collName = [self.class collectionNameForReferencingClassName:className];
	//		NSString * ivarName = [self.class instanceVariableNameForCollectionName:collName];
	//		const char * ivarCName = [ivarName cStringUsingEncoding:NSASCIIStringEncoding];
	//
	//		id array;
	//		object_getInstanceVariable(self, ivarCName, (void **)&array);
	//		object_setInstanceVariable(copy, ivarCName, array);
	//	}
	
	return copy;
}

#pragma mark Miscelaneous

+ (NSArray *)keyNamesForClassName:(NSString *)className
{
	NSMutableArray * keys = [NSMutableArray array];
	
	NSString * keyID = @"id";
	NSString * keyEntityID = [NSString stringWithFormat:@"%@%@", className, keyID];
	NSString * keyEntity_ID = [NSString stringWithFormat:@"%@_%@", className, keyID];
	
	for (NSString * name in self.mappedNames)
		if ([name isEqualToString:keyID ignoreCase:YES] ||
			[name isEqualToString:keyEntityID ignoreCase:YES] ||
			[name isEqualToString:keyEntity_ID ignoreCase:YES])
			[keys addObject:name];
	
	return [NSArray arrayWithArray:keys];
}

+ (NSString *)instanceVariableNameForCollectionName:(NSString *)collectionName
{
	return [@"_" stringByAppendingString:collectionName];
}

@end
