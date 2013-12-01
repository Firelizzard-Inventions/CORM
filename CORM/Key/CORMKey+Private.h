//
//  CORMKey.h
//  CORM
//
//  Created by Ethan Reesor on 12/1/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import "CORMKey.h"

@interface CORMKey ()

- (NSArray *)propertiesForEntityType:(Class<CORMMapping>)type;
- (NSArray *)values;

@end
