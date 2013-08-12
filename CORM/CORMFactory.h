//
//  CORMClass.h
//  CORM
//
//  Created by Ethan Reesor on 7/26/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CORMEntity.h"

@class CORMStore;

@interface CORMFactory : NSObject

@property (readonly) Class<CORMEntity> type;
@property (readonly) CORMStore * store;

- (id)objectForKeyedSubscript:(id)key;

@end