//
//  Album.h
//  CORM
//
//  Created by Ethan Reesor on 8/22/13.
//  Copyright (c) 2013 Firelizzard Inventions. Some rights reserved, see license.
//

#import <CORM/CORMEntityAuto.h>

@interface Album : CORMEntityAuto

@property (retain) NSNumber * albumID, * artistID;
@property (retain) NSString * title;

@property (retain) CORMEntity * artist;

@property (readonly) NSArray * tracks;

@end
