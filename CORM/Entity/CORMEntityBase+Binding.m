//
//  CORMEntity.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityBase+Private.h"

#import <TypeExtensions/TypeExtensions.h>

@implementation CORMEntityBase (Binding)

- (void)bindTo:(id)object withOptions:(CORMEntityBindingOption)options
{
	id proxy = self.zeroingWeakReferenceProxy;
	
	id mappedNames;
	if ([object respondsToSelector:@selector(allKeys)])
		mappedNames = [object allKeys];
	else
		mappedNames = [self.class mappedNames];
	
	[self.bound addObject:[[[_BoundObjectData alloc] initWithProxy:proxy andObject:object names:mappedNames] autorelease]];
	
	for (NSString * mappedName in mappedNames) {
		NSString * propertyName = [self.class propertyNameForMappedName:mappedName];
		
		if (options & kCORMEntityBindingOptionSetReceiverFromObject)
			[self setValue:[object valueForKey:mappedName] forKey:propertyName];
		else if (options & kCORMEntityBindingOptionSetObjectFromReceiver)
			[object setValue:[self valueForKey:propertyName] forKey:mappedName];
		
		[object addObserver:proxy forKeyPath:mappedName options:0 context:self.class.bindObjectObservationContext];
		[self addObserver:self forKeyPath:propertyName options:0 context:self.class.bindSelfObservationContext];
	}
}

@end

@implementation _BoundObjectData

- (id)initWithProxy:(id<NSObject>)proxy andObject:(id<NSObject>)object names:(NSArray *)names
{
	if (!(self = [super init]))
		return nil;
	
	_proxy = proxy.retain;
	_object = object.retain;
	_names = names.copy;
	
	return self;
}

- (BOOL)isEqual:(id)object
{
	if (!object)
		return !self.object;
	
	if (object == self)
		return YES;
	
	if (![object isKindOfClass:self.class])
		return [self.object isEqual:object];
	
	_BoundObjectData * other = (_BoundObjectData *)object;
	
	if (!self.object && !other.object)
		return YES;
	
	return [self.object isEqual:other.object];
}

- (void)dealloc
{
	[_proxy release];
	[_object release];
	[_names release];
	
	[super dealloc];
}

@end