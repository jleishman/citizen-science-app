//
//  HABHarmfulAlgalBloomViewController.m
//  Harmful Algal Bloom
//
//  Created by Justin Leishman on 8/1/14.
//  Copyright (c) 2014 Da Bay. All rights reserved.
//

#import "HABHarmfulAlgalBloomViewController.h"

static NSString * const HABHarmfulAlgalBloomWaterColorsName = @"Water Colors";

static NSString * const HABHarmfulAlgalBloomAlgaeColorsName = @"Algae Colors";

@interface HABHarmfulAlgalBloomViewController ()

@property (strong, nonatomic) NSArray *waterColors;

@property (strong, nonatomic) NSArray *algaeColors;

@property (strong, nonatomic) UIPickerView *waterColorPickerView;

@property (strong, nonatomic) UIPickerView *algaeColorPickerView;

@end

@interface HABHarmfulAlgalBloomViewController (UIPickerViewSupport) <UIPickerViewDataSource,
                                                                     UIPickerViewDelegate>

@end

@interface HABHarmfulAlgalBloomViewController (UIImagePickerControllerSupport) <UINavigationControllerDelegate,
                                                                                UIImagePickerControllerDelegate>

@end

@implementation HABHarmfulAlgalBloomViewController

- (void)_updateLatitudeLabel {
    self.latitudeLabel.text = [NSString stringWithFormat:@"%@",
                               self.report.latitude];
    
    [self.latitudeLabel setNeedsLayout];
}

- (void)_updateLongitudeLabel {
    self.longitudeLabel.text = [NSString stringWithFormat:@"%@",
                                self.report.longitude];
    
    [self.longitudeLabel setNeedsLayout];
}

- (void)_updateImageView {
    self.imageView.image = self.report.image;
}

- (void)_updateInterface {
    [self _updateLatitudeLabel];
    [self _updateLongitudeLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.waterColors = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:HABHarmfulAlgalBloomWaterColorsName
                                                                               withExtension:@"plist"]];
    
    self.algaeColors = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:HABHarmfulAlgalBloomAlgaeColorsName
                                                                               withExtension:@"plist"]];
    
    self.waterColorPickerView = [[UIPickerView alloc] init];
    self.waterColorPickerView.dataSource = self;
    self.waterColorPickerView.delegate = self;
    
    self.waterColorTextField.inputView = self.waterColorPickerView;
    
    self.algaeColorPickerView = [[UIPickerView alloc] init];
    self.algaeColorPickerView.dataSource = self;
    self.algaeColorPickerView.delegate = self;
    
    self.algaeColorTextField.inputView = self.algaeColorPickerView;
    
    if (self.report.image == nil) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        
        [self presentViewController:imagePickerController
                           animated:YES
                         completion:NULL];
    }
}

#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView
shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldHighlightRowAtIndexPath = YES;
    
    if ([[self.tableView indexPathForCell:self.waterColorTableViewCell] isEqual:indexPath] == YES) {
        shouldHighlightRowAtIndexPath = NO;
    }
    
    return shouldHighlightRowAtIndexPath;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.tableView indexPathForCell:self.waterColorTableViewCell] isEqual:indexPath] == YES) {
        [self.waterColorTextField becomeFirstResponder];
    }
}

@end

@implementation HABHarmfulAlgalBloomViewController (UIPickerViewSupport)

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    
    if (pickerView == self.waterColorPickerView) {
        numberOfRows = self.waterColors.count;
    }
    else if (pickerView == self.algaeColorPickerView) {
        numberOfRows = self.algaeColors.count;
    }
    
    return numberOfRows;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    NSString *titleForRow = nil;
    
    if (pickerView == self.waterColorPickerView) {
        titleForRow = NSLocalizedStringWithDefaultValue(self.waterColors[row],
                                                        HABHarmfulAlgalBloomWaterColorsName,
                                                        [NSBundle mainBundle],
                                                        @"Unrecognized Color",
                                                        @"Localized description of water color.");
    }
    else if (pickerView == self.algaeColorPickerView) {
        titleForRow = NSLocalizedStringWithDefaultValue(self.algaeColors[row],
                                                        HABHarmfulAlgalBloomAlgaeColorsName,
                                                        [NSBundle mainBundle],
                                                        @"Unrecognized Color",
                                                        @"Localized description of algae color.");
    }
    
    return titleForRow;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    if (pickerView == self.waterColorPickerView) {
        self.report.waterColor = self.waterColors[row];
    }
    else if (pickerView == self.algaeColorPickerView) {
        self.report.algaeColor = self.algaeColors[row];
    }
}

@end

@implementation HABHarmfulAlgalBloomViewController (MKMapViewSupport)

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.report.latitude = @(userLocation.location.coordinate.latitude);
    self.report.longitude = @(userLocation.location.coordinate.longitude);
    
    [self _updateLatitudeLabel];
    [self _updateLongitudeLabel];
}

@end

@implementation HABHarmfulAlgalBloomViewController (UIImagePickerControllerSupport)

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.report.image = image;
    
    [self _updateImageView];
    
    [self dismissViewControllerAnimated:YES
                             completion:NULL];
}

@end
