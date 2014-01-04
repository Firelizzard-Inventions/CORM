//
//  ORDAGovernor.h
//  ORDA
//
//  Created by Ethan Reesor on 8/11/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "ORDAResult.h"

@protocol ORDAStatement, ORDATable;

/**
 * The ORDAGovernor protocol is the primary point of interaction with or gateway
 * to the API. It governs or manages a 'connection' to a relational database
 * (RDBMSes like SQLite have open files rather than open sockets/connections). A
 * 'connection' to a database is opened upon initialization and closed upon
 * deallocation.
 */
@protocol ORDAGovernor <ORDAResult>

/** ----------------------------------------------------------------------------
 * @name SQL Statements
 */

/**
 * Creates a (prepared) statement
 * @param format the format string
 * @param ... the format string arguments
 * @return the statement
 * @discussion This returns a statement prepared with the specified format
 * string.
 * @see ORDAStatement
 * @see +[NSString stringWithFormat:]
 */
- (id<ORDAStatement>)createStatement:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/** ----------------------------------------------------------------------------
 * @name Database Tables
 */

/**
 * Creates a 'table'
 * @param tableName the name of the database table
 * @return the 'table'
 * @discussion This creates and returns a 'table' object associated with the
 * specified database table.
 * @see ORDATable
 */
- (id<ORDATable>)createTable:(NSString *)tableName;

@end
