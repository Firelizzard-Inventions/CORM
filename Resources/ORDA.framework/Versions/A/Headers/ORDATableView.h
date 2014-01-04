//
//  ORDATableView.h
//  ORDA
//
//  Created by Ethan Reesor on 11/29/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ORDATableResult.h"

@protocol ORDATable;

/**
 * Instances of the ORDATableView protocol represent SQL views.
 */
@protocol ORDATableView <ORDATableResult>

/** ----------------------------------------------------------------------------
 * @name Metadata
 */

/**
 * @return the table this view was created from
 */
- (id<ORDATable>)table;

/** ----------------------------------------------------------------------------
 * @name Data
 */

/**
 * @return the set of keys of the results
 */
- (NSArray *)keys;

@end
