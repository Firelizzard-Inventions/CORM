//
//  ORDASQLite.h
//  ORDA
//
//  Created by Ethan Reesor on 8/11/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <Foundation/Foundation.h>

/**
 * CocoaSQLite is the only outward facing component of the ORDA SQLite driver.
 *
 * @name Updating Tables
 * Tables are automatically updated by means of governors calling
 * `sqlite3_update_hook(sqlite3*, void(*)(void *, int, char const *,
 * char const *, sqlite3_int64), void*)`. However, if manual updating is desired
 * (for instance, if another update hook is registered), `-[ORDATable
 * tableUpdateDidOccur:forRowWithId:]` can be called. The key parameter to is to
 * be either the ROWID or a complete WHERE clause (not including 'WHERE'), such
 * as `MyPrimaryKeyRow = SomeKeyValue`, that can be used to retreive the correct
 * ROWID.
 */
@interface CocoaSQLite : NSObject

/**
 * Registers the ORDA SQLite driver
 */
+ (void)register;

/**
 * @return "sqlite", the ORDA SQLite URL scheme
 */
+ (NSString *)scheme;

@end
