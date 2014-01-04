//
//  ORDATable.h
//  ORDA
//
//  Created by Ethan Reesor on 8/24/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ORDAResult.h"

@protocol ORDAStatementResult, ORDATableResult, ORDATableView;

/**
 * The ORDATable protocol specifies methods that can be used to manage and
 * retrieve results from a database table. Each table maintains a dictionary of
 * result row objects (those returned by -[ORDATableResult
 * objectAtIndexedSubscript:]) indexed by ID (for example, rowid in the SQLite
 * implementation) such that, for any given ID, the same pointer will always be
 * returned. This dictionary is an instance of
 * NSMutableDictionary_NonRetaining_Zeroing - thus, when there are no other
 * references to the row object besides the dictionary's, the object is removed
 * from the dictionary and deallocated. Each row object is syncrhonized with the
 * database such that changing the database changes the object and vice versa.
 */
@protocol ORDATable <ORDAResult>

/** ----------------------------------------------------------------------------
 * @name Metadata
 */

/**
 * @return the associated table's name
 */
- (NSString *)name;

/**
 * @return the associated table's field names
 */
- (NSArray *)columnNames;

/**
 * @return the associated table's primary key's names
 */
- (NSArray *)primaryKeyNames;

/**
 * @return the associated table's foreign key's names
 */
- (NSArray *)foreignKeyTableNames;

/** ----------------------------------------------------------------------------
 * @name Retreiving Row Entities
 */

/**
 * Selects rows from the table
 * @param format the format string for the where clause
 * @param ... the format string arguments
 * @return the selected rows
 * @discussion This method runs 'SELECT * FROM <tableName> WHERE <whereClause>'
 * on the table and returns the resulting rows.
 * @see +[NSString stringWithFormat:]
 */
- (id<ORDATableResult>)selectWhere:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/**
 * Inserts values into the table
 * @param values an object containing the values
 * @param ignoreCase whether or not to ignore the case of the column names
 * @return the inserted row
 * @discussion This method performs 'INSERT INTO <tableName> VALUES (<values>)'
 * and then returns the result of 'SELECT * FROM <tableName> WHERE {primary key}
 * = <lastID>'. The values are retrieved using -[NSObject valueForKey:].
 */
- (id<ORDATableResult>)insertValues:(id)values ignoreCase:(BOOL)ignoreCase;

/**
 * Updates a row in the table
 * @param column the field to update
 * @param value the value to set the field to
 * @param format the format string for the where clause
 * @param ... the format string arguments
 * @return the updated rows
 * @discussion This method runs 'UPDATE <tableName> SET <column> = <value> WHERE
 * <whereClause>' and then returns the result of 'SELECT * FROM <tableName>
 * WHERE <whereClause>'.
 * @see +[NSString stringWithFormat:]
 */
- (id<ORDATableResult>)updateSet:(NSString *)column to:(id)value where:(NSString *)format, ... NS_FORMAT_FUNCTION(3,4);

/**
 * Deletes from the table
 * @param format the format string for the where clause
 * @param ... the format string arguments
 * @return the statement result
 * @discussion This method runs 'DELETE FROM <tableName> WHERE <whereClause>' on
 * the table and returns the number of rows deleted.
 * @see +[NSString stringWithFormat:]
 */
- (id<ORDAStatementResult>)deleteWhere:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/**
 * Creates a 'view' of the selected rows
 * @param format the format string for the where clause
 * @param ... the format string arguments
 * @return the view
 * @discussion This method returns an object that represents a view containing
 * the results of 'SELECT * FROM <tableName> WHERE <whereClause>'.
 * @see ORDATableView
 * @see +[NSString stringWithFormat:]
 */
- (id<ORDATableView>)viewWhere:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/** ----------------------------------------------------------------------------
 * @name Updating Row Entities
 */

/**
 * Notifies the table of an update
 * @param type the update type
 * @param key the updated row's key
 * @return a result code (success or otherwise)
 * @discussion This method is used internally by drivers that have a mechanism
 * for inserting update hooks, thus providing automatic updating of table
 * entities. Some drivers do not natively have this capability.
 * @warning Interpretation of the key parameter is driver dependent and may be
 * unintuitive, especially for drivers that implement automatic updating.
 */
- (id<ORDAResult>)tableUpdateDidOccur:(ORDATableUpdateType)type toRowWithKey:(id)key;

@end
