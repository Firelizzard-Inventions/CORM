//
//  CORMEntity.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMEntityImpl.h"
#import "CORMEntityImpl+Private.h"

#import "CORM.h"
#import "CORMFactory.h"
#import "CORMStore.h"
#import "CORMKey.h"
#import "CORMEntityDict.h"

#import <TypeExtensions/NSString+isEqualToStringIgnoreCase.h>
#import <TypeExtensions/NSObject+associatedObject.h>
#import <TypeExtensions/NSString+firstLetterCaseString.h>
#import <TypeExtensions/NSObject+zeroingWeakReferenceProxy.h>
#import <TypeExtensions/NSObject+DeallocListener.h>

#import <objc/runtime.h>


@implementation CORMEntityImpl

+ (void)initialize
{
	if (![self className])
		return;
	
	if ([[self className] hasPrefix:@"NSKVONotifying_"])
		return;
	
	if ([[self className] hasPrefix:@"DeallocListener_"])
		return;
	
	[self registerWithDefaultStore];
}

+ (void)registerWithDefaultStore
{
	[self registerWithStore:[CORM defaultStore]];
}

+ (void)registerWithStore:(CORMStore *)store
{
	[(NSObject *)self setAssociatedObject:[store registerFactoryForType:self] forSelector:@selector(registeredFactory)];
}

+ (id<CORMFactory>)registeredFactory
{
	if (![(NSObject *)self associatedObjectForSelector:_cmd])
		[self registerWithDefaultStore];
	
	return [(NSObject *)self associatedObjectForSelector:_cmd];
}

+ (id<CORMEntity>)entityForKey:(id)key
{
	return [[self registeredFactory] entityForKey:[CORMKey keyWithObject:key]];
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

- (id)copyWithZone:(NSZone *)zone
{
	CORMEntityImpl * copy = [[[self class] alloc] init];
	
	for (NSString * mappedName in [[self class] mappedNames]) {
		NSString * prop = [[self class] propertyNameForMappedName:mappedName];
		[copy setValue:[self valueForKey:prop] forKey:prop];
	}
	
	return copy;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSArray * propNames = context;
	if (![propNames isKindOfClass:NSArray.class])
		return;
	
	NSString * className = [self.class classNameForForeignKeyPropertyNames:propNames];
	Class theClass = NSClassFromString(className);
	if (theClass && ![theClass conformsToProtocol:@protocol(CORMEntity)])
		return;
	
	CORMStore * store = [self.class registeredFactory].store;
	if (!theClass && !store.generateClasses)
		return;
	
	if (!theClass)
		if (!(theClass = [store generateClassForName:className]))
			return;
	
	NSMutableArray * props = [NSMutableArray array];
	for (NSString * propName in propNames)
		[props addObject:[self valueForKey:propName]];
	
	id obj = [[theClass registeredFactory] entityOrProxyForKey:[CORMKey keyWithArray:props]];
	NSString * prop = [self.class propertyNameForForeignKeyClassName:className];
	[self setValue:obj forKey:prop];
}

#pragma mark - Genesis

+ (id<CORMEntity>)entity
{
	return [[[self alloc] init] autorelease];
}

+ (id<CORMEntity>)entityByBindingTo:(id)obj
{
	return [[[self alloc] initByBindingTo:obj] autorelease];
}

- (id)init
{
	if (!(self = [super init]))
		return nil;
	
	_source = nil;
	_valid = YES;
	
	[self startDeallocationNofitication];
	for (NSString * className in [self.class mappedForeignKeyClassNames]) {
		NSArray * propNames = [self.class propertyNamesForForeignKeyClassName:className];
		for (NSString * propName in propNames)
			[self addObserver:self forKeyPath:propName options:0 context:propNames];
	}
	
	return self;
}

- (id)initByBindingTo:(id)obj
{
	if (!(self = [self init]))
		return nil;
	
	if (!obj)
		return nil;
	
	_source = [obj retain];
	
	NSArray * names = [[self class] mappedNames];
	if ([self.source respondsToSelector:@selector(allKeys)])
		names = [self.source allKeys];
		
	id proxy = self.zeroingWeakReferenceProxy;
	for (NSString * name in names) {
		NSString * prop = [[self class] propertyNameForMappedName:name];
		[self bind:prop toObject:self.source withKeyPath:name options:@{}];
		[self.source bind:name toObject:proxy withKeyPath:prop options:@{}];
	}
	
	return self;
}

- (void)setNilValueForKey:(NSString *)key
{
	SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@:", key.firstLetterUppercaseString]);
	if (!sel)
		[super setNilValueForKey:key];
	if (![self respondsToSelector:sel])
		[super setNilValueForKey:key];
	
	[self performSelector:sel withObject:nil];
}

- (void)invalidate
{
	if (!self.valid)
		return;
	
	if (_source) {
		for (NSString * mappedName in [[self class] mappedNames]) {
			NSString * prop = [[self class] propertyNameForMappedName:mappedName];
			[self unbind:prop];
			[self.source unbind:prop];
		}
	}
	[_source release];
	_source = nil;
	
	for (NSString * mappedName in [[self class] mappedNames])
		[self setValue:nil forKey:[[self class] propertyNameForMappedName:mappedName]];
	
	_valid = NO;
}

- (void)dealloc
{
	for (NSString * className in [self.class mappedForeignKeyClassNames]) {
		NSArray * propNames = [self.class propertyNamesForForeignKeyClassName:className];
		for (NSString * propName in propNames)
			[self removeObserver:self forKeyPath:propName context:propNames];
	}
	
	[self invalidate];
	
	[super dealloc];
}

#pragma mark - Mapping

+ (NSArray *)keyNamesForClassName:(NSString *)className
{
	NSMutableArray * keys = [NSMutableArray array];
	
	NSString * keyID = @"id";
	NSString * keyEntityID = [NSString stringWithFormat:@"%@%@", className, keyID];
	NSString * keyEntity_ID = [NSString stringWithFormat:@"%@_%@", className, keyID];
	
	for (NSString * name in [self mappedNames])
		if ([name isEqualToString:keyID ignoreCase:YES] ||
			[name isEqualToString:keyEntityID ignoreCase:YES] ||
			[name isEqualToString:keyEntity_ID ignoreCase:YES])
			[keys addObject:name];
	
	return keys.copy;
}

+ (BOOL)propertyNamesAreCaseSensitive
{
	return YES;
}

+ (NSString *)mappedClassName
{
	return [self className];
}

+ (NSArray *)mappedKeys
{
	NSArray * keys = [self associatedObjectForSelector:_cmd];
	
	if (!keys) {
		keys = [self keyNamesForClassName:[self mappedClassName]];
		[(NSObject *)self setAssociatedObject:keys forSelector:_cmd];
	}
	
	if (!keys)
		goto throw;
	
	if (!keys.count)
		goto throw;
	
	return keys;
	
throw:
	[NSException raise:kCORMEntityBadKeysException format:@"Could not find sutable ID field to be key, please override"];
	return nil;
}

+ (NSArray *)mappedNames
{
	NSArray * names = [self associatedObjectForSelector:_cmd];
	
	if (!names) {
		unsigned int count;
		objc_property_t * properties = class_copyPropertyList(self, &count);
		
		NSMutableArray * _names = [NSMutableArray arrayWithCapacity:count];
		for (int i = 0; i < count; i++)
			_names[i] = @(property_getName(properties[i]));
		
		free(properties);
		
		for (NSString * className in [self mappedForeignKeyClassNames])
			[_names removeObject:[[self class] propertyNameForForeignKeyClassName:className]];
		
		names = [NSArray arrayWithArray:_names];
		[(NSObject *)self setAssociatedObject:names forSelector:_cmd];
	}
	
	return names;
}

+ (NSArray *)mappedForeignKeyClassNames
{
	return @[];
}

+ (NSString *)mappedNameForPropertyName:(NSString *)propName
{
	if (![[self mappedNames] containsObject:propName])
		return nil;
	
	return propName;
}

+ (NSString *)propertyNameForMappedName:(NSString *)mappedName
{
	for (NSString * name in [self mappedNames])
		if ([name isEqualToString:mappedName ignoreCase:![self propertyNamesAreCaseSensitive]])
			return name;
	
	return nil;
}

+ (NSString *)classNameForForeignKeyPropertyNames:(NSArray *)propNames
{
	NSString * name = propNames[0];
	
	if ([name hasSuffix:@"id"] || [name hasSuffix:@"Id"] || [name hasSuffix:@"ID"])
		name = [name substringToIndex:name.length - 2];
	
	if ([name hasSuffix:@"_id"] || [name hasSuffix:@"_Id"] || [name hasSuffix:@"_ID"])
		name = [name substringToIndex:name.length - 3];
	
	return name.firstLetterUppercaseString;
}

+ (NSArray *)propertyNamesForForeignKeyClassName:(NSString *)className
{
	NSMutableArray * names = [NSMutableArray array];
	
	for (NSString * key in [self keyNamesForClassName:className])
		[names addObject:[self propertyNameForMappedName:key]];
	
	return [NSArray arrayWithArray:names];
}

+ (NSString *)propertyNameForForeignKeyClassName:(NSString *)className
{
	return className.firstLetterLowercaseString;
}

@end