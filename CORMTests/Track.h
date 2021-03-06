//
//  Track.h
//  CORM
//
//  Created by Ethan Reesor on 8/22/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <CORM/CORMEntityAuto.h>

@class Album;

@interface Track : CORMEntityAuto

@property (retain) NSString * name, * composer;
@property (retain) NSNumber * trackID, * albumID, * mediaTypeID, * genreID, * milliseconds, * bytes, * unitPrice;

@property (retain) Album * album;
@property (retain) CORMEntity * genre, * mediaType;

@end