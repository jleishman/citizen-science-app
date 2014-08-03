//
//  CSHarmfulAlgalBloomReport.h
//  Harmful Algal Bloom
//
//  Created by Justin Leishman on 8/2/14.
//  Copyright (c) 2014 Da Bay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CSHarmfulAlgalBloomReport : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) UIImage * image;
@property (nonatomic, retain) NSString * waterColor;
@property (nonatomic, retain) NSString * algaeColor;
@property (nonatomic, retain) NSDate * timestamp;

@end
