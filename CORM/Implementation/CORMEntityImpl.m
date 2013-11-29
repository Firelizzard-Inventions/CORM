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
#import "CORMEntityProxy.h"

#import <TypeExtensions/TypeExtensions.h>
#import <TypeExtensions/String.h>

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

@implementation CORMEntityImpl {
	CORMKey * _key;
	BOOL _valid;
	NSMutableArray * _boundObjects;
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
}

+ (BOOL)propertyNamesAreCaseSensitive
{
	return YES;
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
	
	[self startDeallocationNofitication];
	for (NSString * className in [self.class mappedForeignKeyClassNames]) {
		NSArray * propNames = [self.class propertyNamesForForeignKeyClassName:className];
		for (NSString * propName in propNames)
			[self addObserver:self forKeyPath:propName options:0 context:nil];
	}
	
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
	
	for (NSString * mappedName in [self.class mappedNames]) {
		NSString * prop = [self.class propertyNameForMappedName:mappedName];
		[copy setValue:[self valueForKey:prop] forKey:prop];
	}
	
	return copy;
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
	
	for (NSString * mappedName in [self.class mappedNames])
		[self setValue:nil forKey:[self.class propertyNameForMappedName:mappedName]];
	
	for (NSString * className in [self.class mappedForeignKeyClassNames]) {
		NSArray * propNames = [self.class propertyNamesForForeignKeyClassName:className];
		for (NSString * propName in propNames)
			[self removeObserver:self forKeyPath:propName context:nil];
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
	
	id obj = [[theClass registeredFactory] entityOrProxyForKey:[CORMKey keyWithArray:props]];
	if ([[obj class] isSubclassOfClass:CORMEntityProxy.class])
		obj = ((CORMEntityProxy *)obj).entity;
	
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

- (CORMKey *)key
{
	if (_key)
		goto _return;
	
	NSMutableArray * elems = [NSMutableArray array];
	
	for (NSString * mappedKey in [self.class mappedKeys])
		[elems addObject:[self valueForKey:[self.class propertyNameForMappedName:mappedKey]]];
	
	_key = [[CORMKey alloc] initWithArray:elems];
	
_return:
	return _key;
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

#pragma mark Genesis

+ (id<CORMEntity>)unboundEntity
{
	return [[[self alloc] init] autorelease];
}

+ (id<CORMEntity>)entityForKey:(id)key
{
	return [self.registeredFactory entityForKey:[CORMKey keyWithObject:key]];
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

@end