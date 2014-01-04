//
//  ORDAStatementResult.h
//  ORDA
//
//  Created by Ethan Reesor on 8/11/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "ORDAResult.h"

/**
 * The ORDAStatementResult protocol is the protocol that all statement results
 * must conform to.
 */
@protocol ORDAStatementResult <ORDAResult>

/** ----------------------------------------------------------------------------
 * @name Properties
 */

/**
 * @return the number of inserted, updated, or deleted rows or -1 for select
 */
- (long long)changed;

/**
 * @return the number of result rows
 */
- (long)rows;

/**
 * @return the number of result columns
 */
- (long)columns;

/**
 * @return the ID of the last inserted row, or -1 for select, update, or delete
 */
- (long long)lastID;

/** ----------------------------------------------------------------------------
 * @name Data
 */

/**
 * Treats the result as an array of dictionaries
 * @param idx the row index
 * @return the idx'th row's data, index by column name
 */
- (NSDictionary *)objectAtIndexedSubscript:(NSUInteger)idx;

/**
 * Treats the result as a dictionary of arrays
 * @param key the column name
 * @return the specified column's data, indexed by row index
 */
- (NSArray *)objectForKeyedSubscript:(id)key;

@end
