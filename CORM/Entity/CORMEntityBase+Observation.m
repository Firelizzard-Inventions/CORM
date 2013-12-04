//
//  CORMEntity.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityBase+Private.h"

#import "CORMStore.h"
#import "CORMFactory.h"

@implementation CORMEntityBase (Observation)

- (void)observeValueForKeyName:(NSString *)keyName
{
	[self clearKey];
}

- (void)observeValueForKeyPathAndUpdateBoundObjects:(NSString *)keyPath
{
	for (_BoundObjectData * pair in self.bound)
		[pair.object setValue:[self valueForKey:keyPath] forKey:[self.class mappedNameForPropertyName:keyPath]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofBoundObject:(id)object
{
	[self setValue:[object valueForKey:keyPath] forKey:[self.class propertyNameForMappedName:keyPath]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	static NSLock * lock = nil;
	
	if (!lock)
		lock = [[NSLock alloc] init];
	
	if ([self.class.bindObjectObservationContext isEqual:context])
		goto _other;
	else if ([self.class.bindSelfObservationContext isEqual:context])
		goto _self;
	
_super:
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	return;
	
_other:
	if (![self.bound containsObject:[[[_BoundObjectData alloc] initWithProxy:nil andObject:object names:nil] autorelease]])
		return;
	
	if (![lock tryLock])
		return;
	
	[self observeValueForKeyPath:keyPath ofBoundObject:object];
	[lock unlock];
	
	return;
	
_self:
	for (NSString * mappedKey in self.class.mappedKeys)
		if ([[self.class propertyNameForMappedName:mappedKey] isEqualToString:keyPath])
			[self observeValueForKeyName:keyPath];
	
	if (![lock tryLock])
		return;
	
	[self observeValueForKeyPathAndUpdateBoundObjects:keyPath];
	[lock unlock];
	
	return;
}

@end