//
//  HABHarmfulAlgalBloomViewController.h
//  Harmful Algal Bloom
//
//  Created by Justin Leishman on 8/1/14.
//  Copyright (c) 2014 Da Bay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HABHarmfulAlgalBloomViewController : UITableViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableViewCell *waterColorTableViewCell;

@property (weak, nonatomic) IBOutlet UITextField *waterColorTextField;

@end
