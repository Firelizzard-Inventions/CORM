
//  CORMEntity.m
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "CORMEntityImpl.h"
#import "CORMEntityImpl+Private.h"

#import "CORM.h"
#import "CORMEntityDict.h"
#import "CORMEntityProxy.h"

#import <TypeExtensions/TypeExtensions.h>
#import <TypeExtensions/String.h>
#import <ORDA/ORDA.h>

#import <objc/runtime.h>

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

#pragma mark -
#pragma mark -

@implementation CORMEntityImpl {
	CORMKeyImpl * _key;
	BOOL _valid;
	NSMutableArray * _boundObjects;
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
 */

+ (void)synthesize
{/*
	for (NSString * referencingClassName in self.referencingClassNames) {
		NSString * collectionName = [self collectionNameForReferencingClassName:referencingClassName];
		NSString * CollectionName = collectionName.firstLetterUppercaseString;

		class_addMethod(self, NSSelectorFromString([NSString stringWithFormat:@"countOf%@", CollectionName]),          (IMP)&countOfKey, "Q@:");
		class_addMethod(self, NSSelectorFromString([NSString stringWithFormat:@"%@AtIndexes", collectionName]),        (IMP)&keyAtIndexes, "@@:@");
		class_addMethod(self, NSSelectorFromString([NSString stringWithFormat:@"insert%@:atIndexes", CollectionName]), (IMP)&insertKey_atIndexes, "v@:@@");
		class_addMethod(self, NSSelectorFromString([NSString stringWithFormat:@"remove%@AtIndexes", CollectionName]),  (IMP)&removeKeyAtIndexes, "v@:@");
	}
*/}

+ (BOOL)propertyNamesAreCaseSensitive
{
	return YES;
}

+ (NSString *)instanceVariableNameForCollectionName:(NSString *)collectionName
{
	return [@"_" stringByAppendingString:collectionName];
}

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

- (id)init
{
	if (!(self = [super init]))
		return nil;
	
	_key = nil;
	_boundObjects = @[].mutableCopy;
	_valid = YES;
	_views = nil;
	
	[self startDeallocationNofitication];
	
	for (NSString * className in self.class.mappedForeignKeyClassNames)
		for (NSString * propName in [self.class propertyNamesForForeignKeyClassName:className])
			[self addObserver:self forKeyPath:propName options:0 context:nil];
	
	return self;
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
	CORMEntityImpl * copy = [[self.class alloc] init];
	
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

- (void)buildCollections
{
	NSMutableDictionary * views = [NSMutableDictionary dictionary];
	for (NSString * className in self.class.referencingClassNames) {
		Class theClass = NSClassFromString(className);
		if (!theClass)
			return;
		if (![theClass conformsToProtocol:@protocol(CORMEntity)])
		  return;
		
		NSString * collName = [self.class collectionNameForReferencingClassName:className];
		NSObject<ORDATableView> * view = [[theClass registeredFactory] createViewForKey:self.key];
		[view addObserver:self forKeyPath:@"self" options:0 context:nil];
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
	
	NSString * ivarName = [self.class instanceVariableNameForCollectionName:collectionName];
	const char * ivarCName = [ivarName cStringUsingEncoding:NSASCIIStringEncoding];
	
	id old;
	object_getInstanceVariable(self, ivarCName, (void **)&old);
	
	id entities = [NSMutableArray array];
	for (id key in view.keys)
		[entities addObject:[self.class.registeredFactory entityOrProxyForKey:[CORMKeyImpl keyWithRowid:key]]];
	entities = [[NSArray alloc] initWithArray:entities];
	
	[self willChangeValueForKey:collectionName];
	object_setInstanceVariable(self, ivarCName, entities);
	[self didChangeValueForKey:collectionName];
	
	[old release];
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
	if (!_valid)
		return;
	
	for (_BoundObjectData * obj in _boundObjects) {
		for (NSString * name in obj.names)
			[obj.object removeObserver:obj.proxy forKeyPath:name context:nil];
		for (NSString * mappedName in [self.class mappedNames])
			[self removeObserver:self forKeyPath:[self.class propertyNameForMappedName:mappedName] context:nil];
	}
	[_boundObjects release];
	_boundObjects = nil;
	
	for (id view in _views)
		[view removeObserver:self forKeyPath:@"self" context:nil];
	[_views release];
	_views = nil;
	
	for (NSString * mappedName in self.class.mappedNames)
		[self setValue:nil forKey:[self.class propertyNameForMappedName:mappedName]];
	
	for (NSString * className in self.class.mappedForeignKeyClassNames)
		for (NSString * propName in [self.class propertyNamesForForeignKeyClassName:className])
			[self removeObserver:self forKeyPath:propName context:nil];
	
	for (NSString * className in self.class.referencingClassNames) {
		NSString * collName = [self.class collectionNameForReferencingClassName:className];
		NSString * ivarName = [self.class instanceVariableNameForCollectionName:collName];
		const char * ivarCName = [ivarName cStringUsingEncoding:NSASCIIStringEncoding];
		
		id array;
		object_getInstanceVariable(self, ivarCName, (void **)&array);
		[array release];
		
		[self willChangeValueForKey:collName];
		object_setInstanceVariable(self, ivarCName, nil);
		[self didChangeValueForKey:collName];
	}
	
	_valid = NO;
}

- (void)dealloc
{
	[self invalidate];
	
	[super dealloc];
}

@end

#pragma mark -

@implementation CORMEntityImpl (Registration)

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

@end

#pragma mark -

@implementation CORMEntityImpl (Observation)

- (void)observeValueForKeyName:(NSString *)keyName
{
	[_key release];
	_key = nil;
}

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
	if (theClass && ![theClass conformsToProtocol:@protocol(CORMEntity)])
		return;
	
	CORMStore * store = [self.class registeredFactory].store;
	if (!theClass && !store.generateClasses)
		return;
	
	if (!theClass)
		if (!(theClass = [store generateClassForName:className]))
			return;
	
	id obj = [[theClass registeredFactory] entityOrProxyForKey:[CORMKeyImpl keyWithArray:props]];
//	if ([[obj class] isSubclassOfClass:CORMEntityProxy.class])
//		obj = ((CORMEntityProxy *)obj).entity;
	
	[self setValue:obj forKey:prop];
}

- (void)observeValueForKeyPathAndUpdateBoundObjects:(NSString *)keyPath
{
	for (_BoundObjectData * pair in _boundObjects)
		[pair.object setValue:[self valueForKey:keyPath] forKey:[self.class mappedNameForPropertyName:keyPath]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofBoundObject:(id)object
{
	[self setValue:[object valueForKey:keyPath] forKey:[self.class propertyNameForMappedName:keyPath]];
}

- (void)observeValueOfView:(id<ORDATableView>)view forCollection:(NSString *)collectionName
{
	[self rebuildCollectionForKey:collectionName andView:view];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	static NSLock * lock = nil;
	
	if (!lock)
		lock = [[NSLock alloc] init];
	
	if (object == self) {
		for (NSString * mappedKey in self.class.mappedKeys)
			if ([[self.class propertyNameForMappedName:mappedKey] isEqualToString:keyPath])
				[self observeValueForKeyName:keyPath];
		
		for (NSString * className in self.class.mappedForeignKeyClassNames) {
			NSArray * propNames = [self.class propertyNamesForForeignKeyClassName:className];
			for (NSString * propertyName in propNames)
				if ([propertyName isEqualToStringIgnoreCase:keyPath]) {
					[self observeValueForForeignClassName:className propertyNames:propNames];
					return;
				}
		}
		
		if ([lock tryLock]) {
			[self observeValueForKeyPathAndUpdateBoundObjects:keyPath];
			[lock unlock];
			return;
		}
	} else if ([@"self" isEqualToString:keyPath]) {
		for (NSString * collectionName in [_views allKeysForObject:object])
			[self observeValueOfView:object forCollection:collectionName];
		return;
	} else {
		_BoundObjectData * comp = [[[_BoundObjectData alloc] initWithProxy:nil andObject:object names:nil] autorelease];
		if ([_boundObjects containsObject:comp]) {
			if ([lock tryLock]) {
				[self observeValueForKeyPath:keyPath ofBoundObject:object];
				[lock unlock];
			}
			return;
		}
	}
}

@end

#pragma mark -

@implementation CORMEntityImpl (ConcreteEntity)

#pragma mark Properties

- (CORMKeyImpl *)key
{
	if (_key)
		goto _return;
	
	NSMutableArray * elems = [NSMutableArray array];
	
	for (NSString * mappedKey in [self.class mappedKeys])
		[elems addObject:[self valueForKey:[self.class propertyNameForMappedName:mappedKey]]];
	
	_key = [[CORMKeyImpl alloc] initWithArray:elems];
	
_return:
	return _key;
}

#pragma mark Genesis

+ (id<CORMEntity>)unboundEntity
{
	return [[[self alloc] init] autorelease];
}

+ (id<CORMEntity>)entityForKey:(id)key
{
	return [self.registeredFactory entityForKey:[CORMKeyImpl keyWithObject:key]];
}

+ (id<CORMEntity>)createEntityWithData:(id)data
{
	return [self.registeredFactory createEntityWithData:data];
}

+ (NSArray *)findEntitiesForData:(id)data
{
	return [self.registeredFactory findEntitiesForData:data];
}

+ (NSArray *)findEntitiesWhere:(NSString *)format, ...
{
	NSString * clause;
	if (!format)
		clause = @"1";
	else {
		va_list args;
		va_start(args, format);
		clause = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
		va_end(args);
	}
	
	return [self.registeredFactory findEntitiesWhere:clause];
}

#pragma mark Removal

- (void)delete
{
	[self.class.registeredFactory deleteEntityForKey:self.key];
}

+ (void)deleteEntitiesWhere:(NSString *)format, ...
{
	NSString * clause;
	if (!format)
		clause = @"1";
	else {
		va_list args;
		va_start(args, format);
		clause = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
		va_end(args);
	}
	
	[self.registeredFactory deleteEntitiesWhere:clause];
}

#pragma mark Binding

- (void)bindTo:(id)object withOptions:(CORMEntityBindingOption)options
{
	id proxy = self.zeroingWeakReferenceProxy;
	
	id mappedNames;
	if ([object respondsToSelector:@selector(allKeys)])
		mappedNames = [object allKeys];
	else
		mappedNames = [self.class mappedNames];
	
	[_boundObjects addObject:[[_BoundObjectData alloc] initWithProxy:proxy andObject:object names:mappedNames]];
	
	for (NSString * mappedName in mappedNames) {
		NSString * propertyName = [self.class propertyNameForMappedName:mappedName];
		
		if (options & kCORMEntityBindingOptionSetReceiverFromObject)
			[self setValue:[object valueForKey:mappedName] forKey:propertyName];
		else if (options & kCORMEntityBindingOptionSetObjectFromReceiver)
			[object setValue:[self valueForKey:propertyName] forKey:mappedName];
		
		[object addObserver:proxy forKeyPath:mappedName options:0 context:nil];
		[self addObserver:self forKeyPath:propertyName options:0 context:nil];
	}
}

#pragma mark Mapping

+ (NSString *)mappedClassName
{
	return [self className];
}

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

+ (NSString *)mappedNameForPropertyName:(NSString *)propName
{
	if (![self.mappedNames containsObject:propName])
		return nil;
	
	return propName;
}

+ (NSString *)propertyNameForMappedName:(NSString *)mappedName
{
	if (self.propertyNamesAreCaseSensitive)
		return [self stringIsMappedName:mappedName] ? mappedName : nil;
	
	for (NSString * name in self.mappedNames)
		if ([name isEqualToStringIgnoreCase:mappedName])
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

#pragma mark Collections

+ (NSArray *)referencingClassNames
{
	return @[];
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
	if (self.propertyNamesAreCaseSensitive)
		return [self.mappedKeys containsObject:string];
	
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
		return [self.mappedNames containsObject:string];
	
	static NSArray * lowerCaseNames = nil;
	
	if (!lowerCaseNames) {
		NSMutableArray * lcnames = [NSMutableArray array];
		
		for (NSString * mappedName in self.mappedNames)
			[lcnames addObject:mappedName.lowercaseString];
		
		lowerCaseNames = [[NSArray alloc] initWithArray:lcnames];
	}
	
	return [lowerCaseNames containsObject:string.lowercaseString];
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
		
		for (NSString * mappedName in self.mappedNames) {
			NSString * kprop = [self propertyNameForMappedName:mappedName];
			
			if (!self.propertyNamesAreCaseSensitive)
				kprop = kprop.lowercaseString;
			
			[kprops addObject:kprop];
		}
		
		keyProperties = [[NSArray alloc] initWithArray:kprops];
	}
	
	if (!self.propertyNamesAreCaseSensitive)
		string = string.lowercaseString;
	
	return [keyProperties containsObject:string];
}

+ (BOOL)stringIsMappedProperty:(NSString *)string
{
	static NSArray * properties = nil;
	
	if (!properties) {
		NSMutableArray * props = [NSMutableArray array];
		
		for (NSString * mappedName in self.mappedNames) {
			NSString * prop = [self propertyNameForMappedName:mappedName];
			
			if (!self.propertyNamesAreCaseSensitive)
				prop = prop.lowercaseString;
			
			[props addObject:prop];
		}
		
		properties = [[NSArray alloc] initWithArray:props];
	}
	
	if (!self.propertyNamesAreCaseSensitive)
		string = string.lowercaseString;
	
	return [properties containsObject:string];
}

+ (BOOL)stringIsForeignKeyProperty:(NSString *)string
{
	static NSArray * foreignKeyProperties = nil;
	
	if (!foreignKeyProperties) {
		NSMutableArray * fkprops = [NSMutableArray array];
		
		for (NSString * fkclass in self.mappedForeignKeyClassNames)
			for (NSString * fkprop in [self propertyNamesForForeignKeyClassName:fkclass]) {
				if (!self.propertyNamesAreCaseSensitive)
					fkprop = fkprop.lowercaseString;
				
				[fkprops addObject:fkprop];
			}
		
		foreignKeyProperties = [[NSArray alloc] initWithArray:fkprops];
	}
	
	if (!self.propertyNamesAreCaseSensitive)
		string = string.lowercaseString;
	
	return [foreignKeyProperties containsObject:string];
}

+ (BOOL)stringIsCollectionProperty:(NSString *)string
{
	static NSArray * collectionProperties = nil;
	
	if (!collectionProperties) {
		NSMutableArray * cprops = [NSMutableArray array];
		
		for (NSString * rclass in self.referencingClassNames) {
			NSString * cprop = [self collectionNameForReferencingClassName:rclass];
			
			if (!self.propertyNamesAreCaseSensitive)
				cprop = cprop.lowercaseString;
			
			[cprops addObject:cprop];
		}
		
		collectionProperties = [[NSArray alloc] initWithArray:cprops];
	}
	
	if (!self.propertyNamesAreCaseSensitive)
		string = string.lowercaseString;
	
	return [collectionProperties containsObject:string];
}

@end
