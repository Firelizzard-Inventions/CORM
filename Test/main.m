//
//  main.m
//  Test
//
//  Created by Ethan Reesor on 8/22/13.
//  Copyright (c) 2013 Firelizzard Inventions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CORM/CORM.h>
#import <CORM/CORMStore.h>
#import <ORDA/ORDA.h>
#import <ORDA/ORDASQLite.h>

#import "Track.h"

int main(int argc, const char * argv[])
{

	@autoreleasepool {
	    [ORDASQLite register];
		
		NSString * path = [[NSBundle bundleForClass:[ORDA class]] pathForResource:@"Chinook_Sqlite" ofType:@"sqlite"];
		NSString * str = [NSString stringWithFormat:@"%@:%@", [ORDASQLite scheme], [NSURL fileURLWithPath:path]];
		NSURL * URL = [NSURL URLWithString:str];
		id<ORDAGovernor> gov = [[ORDA sharedInstance] governorForURL:URL];
		[CORM setDefaultStore:[[[CORMStore alloc] initWithGovernor:gov] autorelease]];
		
		Track * track = [Track entityForKey:@"1"];
		NSLog(@"%@", track);
		NSLog(@"%@", track.album);
	}
    return 0;
}

