//
//  HABHarmfulAlgalBloomViewController.h
//  Harmful Algal Bloom
//
//  Created by Justin Leishman on 8/1/14.
//  Copyright (c) 2014 Da Bay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HABHarmfulAlgalBloomViewController : UITableViewController

@property (strong, nonatomic) CSHarmfulAlgalBloomReport *report;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableViewCell *waterColorTableViewCell;

@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;

@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;

@property (weak, nonatomic) IBOutlet UITextField *waterColorTextField;

@end

@interface HABHarmfulAlgalBloomViewController (MKMapViewSupport) <MKMapViewDelegate>

@end