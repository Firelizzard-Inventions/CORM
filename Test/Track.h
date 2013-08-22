//
//  Track.h
//  CORM
//
//  Created by Ethan Reesor on 8/22/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <CORM/CORMEntityImpl.h>

@class Album;

@interface Track : CORMEntityImpl

@property (retain) NSString * name, * composer;
@property (retain) NSNumber * trackID, * albumID, * mediaTypeID, * genreID, * milliseconds, * bytes, * unitPrice;

@property (retain) Album * album;
@property (retain) id<CORMEntity> mediaType, genre;

@end