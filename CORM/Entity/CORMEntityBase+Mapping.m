//
//  CORMEntityBase.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityBase+Private.h"

#import <TypeExtensions/String.h>

@implementation CORMEntityBase (Mapping)

+ (NSString *)propertyNameForMappedName:(NSString *)mappedName
{
	if (self.propertyNamesAreCaseSensitive)
		return [super propertyNameForMappedName:mappedName];
	
	for (NSString * name in self.mappedNames)
		if ([name isEqualToStringIgnoreCase:mappedName])
			return name;
	
	return nil;
}

+ (BOOL)stringIsMappedKey:(NSString *)string
{
	if (self.propertyNamesAreCaseSensitive)
		return [super stringIsMappedKey:string];
	
	static NSArray * lowerCaseKeys = nil;
	
	if (!lowerCaseKeys) {
		NSMutableArray * lckeys = [NSMutableArray array];
		
		for (NSString * mappedName in self.mappedKeys)
			[lckeys addObject:mappedName.lowercaseString];
		
		lowerCaseKeys = [[NSArray alloc] initWithArray:lckeys];
	}
	
	return [lowerCaseKeys containsObject:string.lowercaseString];
}

+ (BOOL)stringIsMappedName:(NSString *)string
{
	if (self.propertyNamesAreCaseSensitive)
		return [super stringIsMappedName:string];
	
	static NSArray * lowerCaseNames = nil;
	
	if (!lowerCaseNames) {
		NSMutableArray * lcnames = [NSMutableArray array];
		
		for (NSString * mappedName in self.mappedNames)
			[lcnames addObject:mappedName.lowercaseString];
		
		lowerCaseNames = [[NSArray alloc] initWithArray:lcnames];
	}
	
	return [lowerCaseNames containsObject:string.lowercaseString];
}

+ (BOOL)stringIsKeyProperty:(NSString *)string
{
	static NSArray * keyProperties = nil;
	
	if (self.propertyNamesAreCaseSensitive)
		return [super stringIsKeyProperty:string];
	
	if (!keyProperties) {
		NSMutableArray * kprops = [NSMutableArray array];
		
		for (NSString * mappedName in self.mappedNames)
			[kprops addObject:[self propertyNameForMappedName:mappedName].lowercaseString];
		
		keyProperties = [[NSArray alloc] initWithArray:kprops];
	}
	
	return [keyProperties containsObject:string.lowercaseString];
}

+ (BOOL)stringIsMappedProperty:(NSString *)string
{
	static NSArray * properties = nil;
	
	if (self.propertyNamesAreCaseSensitive)
		return [super stringIsMappedProperty:string];
	
	if (!properties) {
		NSMutableArray * props = [NSMutableArray array];
		
		for (NSString * mappedName in self.mappedNames)
			[props addObject:[self propertyNameForMappedName:mappedName].lowercaseString];
		
		properties = [[NSArray alloc] initWithArray:props];
	}
	
	return [properties containsObject:string.lowercaseString];
}

+ (BOOL)stringIsForeignKeyProperty:(NSString *)string
{
	static NSArray * foreignKeyProperties = nil;
	
	if (self.propertyNamesAreCaseSensitive)
		return [super stringIsForeignKeyProperty:string];
	
	if (!foreignKeyProperties) {
		NSMutableArray * fkprops = [NSMutableArray array];
		
		for (NSString * fkclass in self.mappedForeignKeyClassNames)
			for (NSString * fkprop in [self propertyNamesForForeignKeyClassName:fkclass])
				[fkprops addObject:fkprop.lowercaseString];
		
		foreignKeyProperties = [[NSArray alloc] initWithArray:fkprops];
	}
	
	return [foreignKeyProperties containsObject:string.lowercaseString];
}

+ (BOOL)stringIsCollectionProperty:(NSString *)string
{
	static NSArray * collectionProperties = nil;
	
	if (self.propertyNamesAreCaseSensitive)
		return [super stringIsCollectionProperty:string];
	
	if (!collectionProperties) {
		NSMutableArray * cprops = [NSMutableArray array];
		
		for (NSString * rclass in self.referencingClassNames)
			[cprops addObject:[self collectionNameForReferencingClassName:rclass].lowercaseString];
		
		collectionProperties = [[NSArray alloc] initWithArray:cprops];
	}
	
	return [collectionProperties containsObject:string.lowercaseString];
}

@end