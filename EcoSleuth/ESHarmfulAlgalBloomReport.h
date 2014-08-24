//
//  ESHarmfulAlgalBloomReport.h
//  EcoSleuth
//
//  Created by Justin Leishman on 8/2/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ESHarmfulAlgalBloomReport : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * colorInWaterColumn;
@property (nonatomic, retain) UIImage * image;
@property (nonatomic, retain) NSString * waterColor;
@property (nonatomic, retain) NSString * algaeColor;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber *submitted;

@end
