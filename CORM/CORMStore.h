//
//  CORMStore.h
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ORDAGovernor, CORMEntity;
@class CORMFactory;

@interface CORMStore : NSObject

@property BOOL generateClasses;
@property (readonly) id<ORDAGovernor> governor;

- (id)initWithGovernor:(id<ORDAGovernor>)governor;

- (CORMFactory *)factoryRegisteredForType:(Class<CORMEntity>)type;
- (CORMFactory *)registerFactoryForType:(Class<CORMEntity>)type;
- (Class<CORMEntity>)generateClassForName:(NSString *)className;

@end
