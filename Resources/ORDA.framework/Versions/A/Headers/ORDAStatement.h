//
//  ORDAStatement.h
//  ORDA
//
//  Created by Ethan Reesor on 8/11/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import "ORDAResult.h"

@protocol ORDAStatementResult;

/**
 * The ORDAStatement protocol is the protocol that all ORDA statements must
 * conform to. It provides methods to bind values to parameters, access the SQL
 * and results, etc. Instances conforming to this protocol can be expected to
 * maintain a reference to the governor that created them. Thus, all statements
 * must be released before the governor will be deallocated.
 */
@protocol ORDAStatement <ORDAResult, NSFastEnumeration>

/**
 * The statement's SQL
 * @return the SQL
 * This returns the SQL used to create this statement.
 */
- (NSString *)statementSQL;

/**
 * The next statement
 * @return the next statement
 * If the SQL passed to -[ORDAGovernor createStatement:] contained multiple
 * statements separated by semicolons, this returns the statement after this
 * one.
 */
- (id<ORDAStatement>)nextStatement;

/**
 * An enumerator for nextStatement
 * @return an enumerator
 * @discussion The enumerator returned by this method will enumerate through
 * this statement and those it links to as a linked list. Thus this method can
 * be used in conjunction with -[ORDAGovernor createStatement:] to enumerate
 * through a set of statements.
 * @see nextStatement
 */
- (id<NSFastEnumeration>)fastEnumerate;

/** ----------------------------------------------------------------------------
 * @name Results
 */

/**
 * The statement result
 * @return the result of this statement's execution
 * @discussion The first time this method is called after a call to reset, the
 * call will result in the execution of this statement. Every subsequent call
 * until reset is called will return the same pointer.
 */
- (id<ORDAStatementResult>)result;

/**
 * Resets the statement
 * @return nil on no error
 * @discussion This method clears the cached result object and performs any
 * driver specific cleanup.
 */
- (id<ORDAResult>)reset;

/** ----------------------------------------------------------------------------
 * @name Binding
 */

/**
 * Binds data to a parameter
 * @param data the data
 * @param index the parameter index;
 * @return nil on no error
 */
- (id<ORDAResult>)bindBlob:(NSData *)data toIndex:(int)index;

/**
 * Binds a number as a double to a parameter
 * @param number the number
 * @param index the parameter index;
 * @return nil on no error
 */
- (id<ORDAResult>)bindDouble:(NSNumber *)number toIndex:(int)index;

/**
 * Binds a number as an integer to a parameter
 * @param number the number
 * @param index the parameter index;
 * @return nil on no error
 */
- (id<ORDAResult>)bindInteger:(NSNumber *)number toIndex:(int)index;

/**
 * Binds a number as a long to a parameter
 * @param number the number
 * @param index the parameter index;
 * @return nil on no error
 */
- (id<ORDAResult>)bindLong:(NSNumber *)number toIndex:(int)index;

/**
 * Binds null to a parameter
 * @param index the parameter index;
 * @return nil on no error
 */
- (id<ORDAResult>)bindNullToIndex:(int)index;
/**
 * Binds a string to a parameter
 * @param string the string
 * @param encoding the encoding to use
 * @param index the parameter index
 * @return nil on no error
 */
- (id<ORDAResult>)bindText:(NSString *)string withEncoding:(NSStringEncoding)encoding toIndex:(int)index;

/**
 * Clears all bindings
 * @return nil on no error
 * @discussion This method resets any bound parameters.
 */
- (id<ORDAResult>)clearBindings;

@end
