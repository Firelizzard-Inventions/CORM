//
//  CORMEntityBase.m
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMEntityAuto.h"

#import <TypeExtensions/TypeExtensions.h>
#import <TypeExtensions/String.h>

#import "CORMDefaults+Private.h"
#import "CORMKey.h"
#import "CORMEntityBase+Private.h"
#import "CORMFactory.h"

@implementation CORMEntityAuto {
	NSDictionary * _views;
}

+ (void)initialize
{
	NSString * className = NSStringFromClass(self);
	
	if (!className)
		return;
	
	if ([className hasPrefix:@"NSKVONotifying_"])
		return;
	
	if ([className hasPrefix:@"DeallocListener_"])
		return;
	
	if ([className hasPrefix:@"DeallocNotifying_"])
		return;
	
	[self registerWithDefaultStore];
	[self synthesize];
}

+ (id)viewObservationContext
{
	static id _ctxt = nil;
	
	if (!_ctxt)
		_ctxt = [[_ObservationContext contextWithIdentifier:@"com.firelizzard.CORM.observe.entity.view" forContext:CORMEntityAuto.class] retain];
	
	return _ctxt;
}

- (id)init
{
	if (!(self = [super init]))
		return nil;
	
	_views = nil;
	
	return self;
}

- (void)dealloc
{
	for (id view in _views)
		[_views[view] removeObserver:self forKeyPath:@"self" context:self.class.viewObservationContext];
	[_views release];
	_views = nil;
	
	for (NSString * className in self.class.referencingClassNames) {
		NSString * collName = [self.class collectionNameForReferencingClassName:className];
		NSString * ivarName = [self.class instanceVariableNameForCollectionName:collName];
		const char * ivarCName = [ivarName cStringUsingEncoding:NSASCIIStringEncoding];
		
		id array;
		object_getInstanceVariable(self, ivarCName, (void **)&array);
		
		[self willChangeValueForKey:collName];
		object_setInstanceVariable(self, ivarCName, nil);
		[self didChangeValueForKey:collName];
		
		[array release];
	}
	
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (![self.class.viewObservationContext isEqual:context])
		goto _super;
	
	if (![@"self" isEqualToString:keyPath])
		return;
	
	if (![object conformsToProtocol:@protocol(ORDATableView)])
		return;
	
	for (NSString * collectionName in [_views allKeysForObject:object])
		[self rebuildCollectionForKey:collectionName andView:object];
	
	return;
	
_super:
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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

- (void)buildCollections
{
	NSMutableDictionary * views = [NSMutableDictionary dictionary];
	for (NSString * className in self.class.referencingClassNames) {
		Class theClass = NSClassFromString(className);
		if (!theClass)
			return;
		if (![theClass isSubclassOfClass:CORMEntity.class])
			return;
		
		NSString * collName = [self.class collectionNameForReferencingClassName:className];
		NSObject<ORDATableView> * view = [[theClass registeredFactory] createViewForKey:[CORMKey keyWithKey:self.key forEntityType:self.class]];
		if (view.isError)
			return;
		
		[view addObserver:self forKeyPath:@"self" options:0 context:self.class.viewObservationContext];
		views[collName] = view;
		[self rebuildCollectionForKey:collName andView:view];
	}
	_views = [[NSDictionary alloc] initWithDictionary:views];
}

- (void)rebuildCollectionForKey:(NSString *)collectionName andView:(id<ORDATableView>)view
{
	if (!view)
		view = _views[collectionName];
	
	if (!view)
		return;
	
	if (![view conformsToProtocol:@protocol(ORDATableView)])
		@throw [NSException exceptionWithName:kCORMExceptionInternalInconsistency reason:@"Stored view does not conform to protocol" userInfo:0];
	
	NSString * className = [self.class referencingClassNameForCollectionName:collectionName];
	Class theClass = NSClassFromString(className);
	if (!theClass)
		return;
	if (![theClass isSubclassOfClass:CORMEntity.class])
		return;
	
	NSString * ivarName = [self.class instanceVariableNameForCollectionName:collectionName];
	const char * ivarCName = [ivarName cStringUsingEncoding:NSASCIIStringEncoding];
	
	id old;
	object_getInstanceVariable(self, ivarCName, (void **)&old);
	
	id entities = [NSMutableArray array];
	for (id key in view.keys)
		[entities addObject:[[theClass registeredFactory] entityOrProxyForKey:[CORMKey keyWithRowid:key]]];
	entities = [[NSArray alloc] initWithArray:entities];
	
	[self willChangeValueForKey:collectionName];
	object_setInstanceVariable(self, ivarCName, entities);
	[self didChangeValueForKey:collectionName];
	
	[old release];
}

@end

@implementation CORMEntityAuto (Mapping)

+ (NSArray *)mappedKeys
{
	NSArray * keys = [self associatedObjectForSelector:_cmd];
	
	if (!keys) {
		keys = [self keyNamesForClassName:self.mappedClassName].retain;
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
		
		SUPPRESS(-Wobjc-method-access)
		if ([(NSObject *)self respondsToSelector:@selector(excludedPropertyNames)])
			for (NSString * excludedName in (NSArray *)[self excludedPropertyNames])
				[_names removeObject:excludedName];
		UNSUPPRESS()
		
		for (NSString * className in self.mappedForeignKeyClassNames)
			[_names removeObject:[self propertyNameForForeignKeyClassName:className]];
		
		for (NSString * className in self.referencingClassNames)
			[_names removeObject:[self collectionNameForReferencingClassName:className]];
		
		names = [NSArray arrayWithArray:_names];
		[(NSObject *)self setAssociatedObject:names forSelector:_cmd];
	}
	
	return names;
}

+ (NSArray *)mappedForeignKeyClassNames
{
	return @[];
}

@end

@implementation CORMEntityAuto (Synthesize)

/*
 NSString * getPropertyName(SEL selector, NSUInteger first, NSUInteger last) {
 static NSMutableDictionary * cache = nil;
 
 if (!cache)
 cache = [NSMutableDictionary dictionary];
 
 const char * selName = sel_getName(selector);
 NSValue * value = [NSValue valueWithPointer:selName];
 NSString * name = cache[value];
 
 if (name)
 return name;
 
 last += strlen(selName);
 name = [[NSString alloc] initWithBytes:(selName + first) length:(last - first) encoding:NSASCIIStringEncoding];
 name = name.firstLetterLowercaseString;
 
 cache[value] = name;
 return name;
 }
 
 NSUInteger countOfKey(id self, SEL _cmd) {
 NSArray * array = [self valueForKey:getPropertyName(_cmd, 7, 0)];
 
 return array.count;
 }
 
 NSArray * keyAtIndexes(id self, SEL _cmd, NSIndexSet * indexes) {
 NSArray * array = [self valueForKey:getPropertyName(_cmd, 0, -7)];
 
 return [array objectsAtIndexes:indexes];
 }
 
 void insertKey_atIndexes(id self, SEL _cmd, NSArray * objects, NSIndexSet * indexes) {
 NSMutableArray * array = [self valueForKey:getPropertyName(_cmd, 6, -10)];
 
 [array insertObjects:objects atIndexes:indexes];
 }
 
 void removeKeyAtIndexes(id self, SEL _cmd, NSArray * objects, NSIndexSet * indexes) {
 NSMutableArray * array = [self valueForKey:getPropertyName(_cmd, 6, -9)];
 
 [array removeObjectsAtIndexes:indexes];
 }
 //*/

+ (void)synthesize
{
	/*
	 for (NSString * referencingClassName in self.referencingClassNames) {
	 NSString * collectionName = [self collectionNameForReferencingClassName:referencingClassName];
	 NSString * CollectionName = collectionName.firstLetterUppercaseString;
	 
	 class_addMethod(self, NSSelectorFromString([NSString stringWithFormat:@"countOf%@", CollectionName]),          (IMP)&countOfKey, "Q@:");
	 class_addMethod(self, NSSelectorFromString([NSString stringWithFormat:@"%@AtIndexes", collectionName]),        (IMP)&keyAtIndexes, "@@:@");
	 class_addMethod(self, NSSelectorFromString([NSString stringWithFormat:@"insert%@:atIndexes", CollectionName]), (IMP)&insertKey_atIndexes, "v@:@@");
	 class_addMethod(self, NSSelectorFromString([NSString stringWithFormat:@"remove%@AtIndexes", CollectionName]),  (IMP)&removeKeyAtIndexes, "v@:@");
	 }
	 //*/
}

@end
