//
//  ORDAResultConsts.h
//  ORDA
//
//  Created by Ethan Reesor on 8/11/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

typedef int ORDACode;
typedef int ORDADriverCode;
typedef int ORDAResultCodeSubclass;

typedef enum {
	kORDAResultCodeClassMask = 0xF000,
	kORDAResultCodeSubclassMask = 0x0F00,
	kORDAResultCodeCodeMask = 0x00FF
} ORDAResultCodeMask;

typedef enum {
	kORDAResultCodeSucessClass = 0x0000,
	kORDAResultCodeErrorClass = 0x1000,
	kORDAResultCodeDriverClass = 0x2000
} ORDAResultCodeClass;

typedef enum {
	kORDAResultCodeInternalErrorSubclass = 0x0100 | kORDAResultCodeErrorClass,
	kORDAResultCodeConnectionErrorSubclass = 0x0200 | kORDAResultCodeErrorClass,
	kORDAResultCodeStatementErrorSubclass = 0x0300 | kORDAResultCodeErrorClass,
	kORDAResultCodeTableErrorClass = 0x0400 | kORDAResultCodeErrorClass
} ORDAResultCodeErrorSubclass;

typedef enum {
	kORDASucessResultCode = kORDAResultCodeSucessClass,
	
	kORDAErrorResultCode = kORDAResultCodeErrorClass,
	kORDANilDriverErrorResultCode,
	kORDANoMemoryErrorResultCode,
	kORDANilConnectionErrorResultCode,
	kORDAUnknownErrorResultCode,
	
	kORDAInternalErrorResultCode = kORDAResultCodeInternalErrorSubclass,
	kORDAUnimplementedAPIErrorResultCode,
	kORDAInternalAPIMismatchErrorResultCode,
	
	kORDAConnectionErrorResultCode = kORDAResultCodeConnectionErrorSubclass,
	kORDANilURLErrorResultCode,
	kORDAMissingDriverErrorResultCode,
	kORDABadURLErrorResultCode,
	
	kORDAStatementErrorResultCode = kORDAResultCodeStatementErrorSubclass,
	kORDANilGovernorErrorResultCode,
	kORDANilStatementSQLErrorResultCode,
	kORDABadStatementSQLErrorResultCode,
	kORDABadBindIndexErrorResultCode,
	
	kORDATableErrorResultCode = kORDAResultCodeTableErrorClass,
	kORDANilTableNameErrorResultCode,
	kORDANoResultRowsForKeyErrorResultCode,
	kORDANoLastIDForInsertResultCode
	
} ORDAResultCode;

typedef enum {
	kORDARowInsertTableUpdateType,
	kORDARowUpdateTableUpdateType,
	kORDARowDeleteTableUpdateType,
	kORDAUnknownTableUpdateType
} ORDATableUpdateType;