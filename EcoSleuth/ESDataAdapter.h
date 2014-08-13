//
//  ESDataAdapter.h
//  EcoSleuth
//
//  Created by Justin Leishman on 8/12/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ESDataAdapterCompletionBlock)(NSError *error);

@protocol ESDataAdapter <NSObject>

- (void)submitReport:(ESHarmfulAlgalBloomReport *)report
     completionBlock:(ESDataAdapterCompletionBlock)completionBlock;

@end
