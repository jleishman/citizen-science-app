//
//  ESHarmfulAlgalBloomViewController.h
//  EcoSleuth
//
//  Created by Justin Leishman on 8/1/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESHarmfulAlgalBloomViewControllerDelegate;

@interface ESHarmfulAlgalBloomViewController : UITableViewController

@property (weak) id <ESHarmfulAlgalBloomViewControllerDelegate> delegate;

@property (strong, nonatomic) ESHarmfulAlgalBloomReport *report;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableViewCell *waterColorTableViewCell;

@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;

@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;

@property (weak, nonatomic) IBOutlet UITextField *waterColorTextField;

@property (weak, nonatomic) IBOutlet UITextField *algaeColorTextField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)submit;

- (IBAction)cancel;

- (IBAction)captureImage;

@end

@interface ESHarmfulAlgalBloomViewController (MKMapViewSupport) <MKMapViewDelegate>

@end

@protocol ESHarmfulAlgalBloomViewControllerDelegate <NSObject>

- (void)harmfulAlgalBloomViewController:(ESHarmfulAlgalBloomViewController *)harmfulAlgalBloomViewController
                        didSubmitReport:(ESHarmfulAlgalBloomReport *)report;

- (void)harmfulAlgalBloomViewController:(ESHarmfulAlgalBloomViewController *)harmfulAlgalBloomViewController
                 didCancelEditingReport:(ESHarmfulAlgalBloomReport *)report;

@end