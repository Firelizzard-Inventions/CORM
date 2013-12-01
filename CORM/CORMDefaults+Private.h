//
//  CORMDefaults+Private.h
//  CORM
//
//  Created by Ethan Reesor on 11/30/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <CORM/CORM.h>

@protocol ORDAResult;

@interface CORM (Private)

+ (id)handleError:(id<ORDAResult>)errorResult;

@end
