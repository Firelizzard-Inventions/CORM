//
//  CORMEntity.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntity+Private.h"

#import <TypeExtensions/String.h>

@implementation CORMEntity (Mapping)

#pragma mark - Mapping Data Accessors

+ (NSString *)mappedClassName
{
	return @"";
}

+ (NSArray *)mappedKeys
{
	return @[];
}

+ (NSArray *)mappedNames
{
	return @[];
}

+ (NSArray *)mappedForeignKeyClassNames
{
	return @[];
}

+ (NSArray *)referencingClassNames
{
	return @[];
}

#pragma mark - Object/Relational Data Mappers

+ (NSString *)mappedNameForPropertyName:(NSString *)propName
{
	if (![self.mappedNames containsObject:propName])
		return nil;
	
	return propName;
}

+ (NSString *)propertyNameForMappedName:(NSString *)mappedName
{
	return [self stringIsMappedName:mappedName] ? mappedName : nil;
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

+ (NSString *)classNameForForeignKeyPropertyName:(NSString *)propName
{
	return propName.firstLetterUppercaseString;
}

+ (NSString *)propertyNameForForeignKeyClassName:(NSString *)className
{
	return className.firstLetterLowercaseString;
}

+ (NSString *)referencingClassNameForCollectionName:(NSString *)collectionName
{
	NSString * name = collectionName;
	
	if ([name hasSuffix:@"ies"])
		name = [[name substringToIndex:name.length - 3] stringByAppendingString:@"y"];
	else if ([name hasSuffix:@"s"])
		name = [name substringToIndex:name.length - 1];
	
	return name.firstLetterUppercaseString;
}

+ (NSString *)collectionNameForReferencingClassName:(NSString *)className
{
	NSString * name = className;
	
	if ([name hasSuffix:@"y"])
		name = [[name substringToIndex:name.length - 1] stringByAppendingString:@"ies"];
	else
		name = [name stringByAppendingString:@"s"];
	
	return name.firstLetterLowercaseString;
}

#pragma mark Tests

+ (BOOL)stringIsMappedKey:(NSString *)string
{
	return [self.mappedKeys containsObject:string];
}

+ (BOOL)stringIsMappedName:(NSString *)string
{
	return [self.mappedNames containsObject:string];
}

+ (BOOL)stringIsMappedForeignKeyClassName:(NSString *)string
{
	return [self.mappedForeignKeyClassNames containsObject:string];
}

+ (BOOL)stringIsReferencingClassName:(NSString *)string
{
	return [self.referencingClassNames containsObject:string];
}

+ (BOOL)stringIsKeyProperty:(NSString *)string
{
	static NSArray * keyProperties = nil;
	
	if (!keyProperties) {
		NSMutableArray * kprops = [NSMutableArray array];
		
		for (NSString * mappedName in self.mappedNames)
			[kprops addObject:[self propertyNameForMappedName:mappedName]];
		
		keyProperties = [[NSArray alloc] initWithArray:kprops];
	}
	
	return [keyProperties containsObject:string];
}

+ (BOOL)stringIsMappedProperty:(NSString *)string
{
	static NSArray * properties = nil;
	
	if (!properties) {
		NSMutableArray * props = [NSMutableArray array];
		
		for (NSString * mappedName in self.mappedNames)
			[props addObject:[self propertyNameForMappedName:mappedName]];
		
		properties = [[NSArray alloc] initWithArray:props];
	}
	
	return [properties containsObject:string];
}

+ (BOOL)stringIsForeignKeyProperty:(NSString *)string
{
	static NSArray * foreignKeyProperties = nil;
	
	if (!foreignKeyProperties) {
		NSMutableArray * fkprops = [NSMutableArray array];
		
		for (NSString * fkclass in self.mappedForeignKeyClassNames)
			for (NSString * fkprop in [self propertyNamesForForeignKeyClassName:fkclass])
				[fkprops addObject:fkprop];
		
		foreignKeyProperties = [[NSArray alloc] initWithArray:fkprops];
	}
	
	return [foreignKeyProperties containsObject:string];
}

+ (BOOL)stringIsCollectionProperty:(NSString *)string
{
	static NSArray * collectionProperties = nil;
	
	if (!collectionProperties) {
		NSMutableArray * cprops = [NSMutableArray array];
		
		for (NSString * rclass in self.referencingClassNames)
			[cprops addObject:[self collectionNameForReferencingClassName:rclass]];
		
		collectionProperties = [[NSArray alloc] initWithArray:cprops];
	}
	
	return [collectionProperties containsObject:string];
}

@end
