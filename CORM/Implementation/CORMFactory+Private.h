//
//  CORMFactory_private.h
//  CORM
//
//  Created by Ethan Reesor on 7/27/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//
//  PRIVATE HEADER
//

#import "CORMFactory.h"

@interface CORMFactory (Genesis)

+ (id)factoryForEntity:(Class)type fromStore:(CORMStore *)store;
- (id)initWithEntity:(Class)type fromStore:(CORMStore *)store;

@end