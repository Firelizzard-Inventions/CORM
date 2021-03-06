//
//  CORMStore.h
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

@protocol ORDAGovernor;
@class CORMFactory;

@interface CORMStore : NSObject

@property BOOL generateClasses;
@property (readonly) id<ORDAGovernor> governor;

- (id)initWithGovernor:(id<ORDAGovernor>)governor;

- (CORMFactory *)factoryRegisteredForType:(Class)type;
- (CORMFactory *)registerFactoryForType:(Class)type;

@end
