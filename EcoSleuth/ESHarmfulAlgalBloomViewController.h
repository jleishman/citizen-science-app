//
//  ESHarmfulAlgalBloomViewController.h
//  EcoSleuth
//
//  Created by Justin Leishman on 8/1/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESHarmfulAlgalBloomViewController : UITableViewController

@property (strong, nonatomic) ESHarmfulAlgalBloomReport *report;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableViewCell *waterColorTableViewCell;

@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;

@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;

@property (weak, nonatomic) IBOutlet UITextField *waterColorTextField;

@property (weak, nonatomic) IBOutlet UITextField *algaeColorTextField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)submit;

@end

@interface ESHarmfulAlgalBloomViewController (MKMapViewSupport) <MKMapViewDelegate>

@end