//
//  ESAppDelegate.h
//  EcoSleuth
//
//  Created by Justin Leishman on 8/1/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
