//
//  CSHarmfulAlgalBloomReport.m
//  Harmful Algal Bloom
//
//  Created by Justin Leishman on 8/2/14.
//  Copyright (c) 2014 Da Bay. All rights reserved.
//

#import "CSHarmfulAlgalBloomReport.h"


@implementation CSHarmfulAlgalBloomReport

@dynamic latitude;
@dynamic longitude;
@dynamic colorInWaterColumn;
@dynamic image;
@dynamic waterColor;
@dynamic algaeColor;
@dynamic timestamp;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    self.waterColor = @"Blue";
    self.algaeColor = @"Blue";
    self.colorInWaterColumn = @(NO);
    self.timestamp = [NSDate date];
    self.latitude = @(0);
    self.longitude = @(0);
}

- (UIImage *)image {
    UIImage *image = [self primitiveValueForKey:@"image"];
    
    if (image == nil) {
        NSData *imageData = [self primitiveValueForKey:@"imageData"];
        
        if (imageData != nil) {
            image = [UIImage imageWithData:imageData];
            
            [self setPrimitiveValue:image forKey:@"image"];
        }
    }
    
    return image;
}

- (void)setImage:(UIImage *)image {
    NSData *imageData = UIImagePNGRepresentation(image);
    
    [self willChangeValueForKey:@"image"];
    
    [self setPrimitiveValue:image forKey:@"image"];
    
    [self setPrimitiveValue:imageData forKey:@"imageData"];
    
    [self didChangeValueForKey:@"image"];
}

@end
