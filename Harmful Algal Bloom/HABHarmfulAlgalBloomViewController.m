//
//  HABHarmfulAlgalBloomViewController.m
//  Harmful Algal Bloom
//
//  Created by Justin Leishman on 8/1/14.
//  Copyright (c) 2014 Da Bay. All rights reserved.
//

#import "HABHarmfulAlgalBloomViewController.h"

static NSString * const HABHarmfulAlgalBloomWaterColorsName = @"Water Colors";

static NSString * const HABHarmfulAlgalBloomWaterColorsLabelTable = @"Water Color Labels";

@interface HABHarmfulAlgalBloomViewController ()

@property (strong, nonatomic) NSArray *waterColors;

@end

@interface HABHarmfulAlgalBloomViewController (UIPickerViewSupport) <UIPickerViewDataSource,
                                                                     UIPickerViewDelegate>

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

- (void)_updateInterface {
    [self _updateLatitudeLabel];
    [self _updateLongitudeLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.waterColors = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:HABHarmfulAlgalBloomWaterColorsName
                                                                               withExtension:@"plist"]];
    
    UIPickerView *waterColorPickerView = [[UIPickerView alloc] init];
    waterColorPickerView.dataSource = self;
    waterColorPickerView.delegate = self;
    
    self.waterColorTextField.inputView = waterColorPickerView;
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
    return self.waterColors.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    NSString *localizedString = NSLocalizedStringWithDefaultValue(self.waterColors[row],
                                                                  HABHarmfulAlgalBloomWaterColorsLabelTable,
                                                                  [NSBundle mainBundle],
                                                                  @"Unrecognized Color",
                                                                  @"Localized description of water color.");
    
    return localizedString;
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
