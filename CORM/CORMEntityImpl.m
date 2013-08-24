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
#import "CORMFactory+Private.h"
#import "CORMStore.h"
#import "CORMKey.h"
#import "CORMEntityDict.h"

#import <TypeExtensions/NSString+isEqualToStringIgnoreCase.h>
#import <TypeExtensions/NSObject+associatedObjectForSelector.h>
#import <TypeExtensions/NSString+firstLetterCaseString.h>

#import <objc/runtime.h>


@implementation CORMEntityImpl

+ (void)initialize
{
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

+ (CORMFactory *)registeredFactory
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
	unsigned int count;
	objc_property_t * properties = class_copyPropertyList([self class], &count);
	
	NSArray * foreignKeys = [[self class] mappedForeignKeyClassNames];
	NSMutableArray * props = [NSMutableArray arrayWithCapacity:count];
	for (int i = 0; i < count; i++) {
		NSString * prop = [NSString stringWithCString:property_getName(properties[i]) encoding:NSASCIIStringEncoding];
		
		if (![foreignKeys containsObject:prop.firstLetterUppercaseString])
			[props addObject:[NSString stringWithFormat:@"[%@]='%@'", prop, [self valueForKey:prop]]];
	}
	
	free(properties);
	
	return [NSString stringWithFormat:@"<%s: %@>", class_getName([self class]), [props componentsJoinedByString:@", "]];
}

#pragma mark - Genesis

- (id)initWithKey:(id)key
{
	return [self initWithKey:key dictionary:@{}];
}

- (id)initWithKey:(id)key dictionary:(NSDictionary *)dict
{
	if (!(self = [super init]))
		return nil;
	
	// type extensions, WTF?
//	if ([self isMemberOfClass:[CORMEntity class]])
//		[self _subclassImplementationExceptionFromMethod:_cmd isClassMethod:NO];
	
	if (!dict)
		goto exit;
	
	if (!dict.count)
		goto exit;
	
	[self setValuesForKeysWithDictionary:dict];
	
exit:
	return self;
}

+ (CORMEntityImpl *)entityWithKey:(id)key
{
	return [[[self alloc] initWithKey:key] autorelease];
}

+ (CORMEntityImpl *)entityWithKey:(id)key dictionary:(NSDictionary *)dict
{
	return [[[self alloc] initWithKey:key dictionary:dict] autorelease];
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
	return NSStringFromClass(self);
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
			_names[i] = [NSString stringWithCString:property_getName(properties[i]) encoding:NSASCIIStringEncoding];
		
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