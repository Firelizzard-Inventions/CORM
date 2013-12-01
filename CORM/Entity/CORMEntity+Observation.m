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
	if (object == self)
		for (NSString * className in self.class.mappedForeignKeyClassNames) {
			NSArray * propNames = [self.class propertyNamesForForeignKeyClassName:className];
			for (NSString * propertyName in propNames)
				if ([propertyName isEqualToStringIgnoreCase:keyPath])
					[self observeValueForForeignClassName:className propertyNames:propNames];
		}
}

@end