//
//  ViewController.h
//  DataUsage
//
//  Created by Praveen Jha on 12/03/13.
//  Copyright (c) 2013 Praveen Jha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property(nonatomic, strong) IBOutlet UILabel *wifiSent;
@property(nonatomic, strong) IBOutlet UILabel *wifiRcvd;
@property(nonatomic, strong) IBOutlet UILabel *cellularSent;
@property(nonatomic, strong) IBOutlet UILabel *cellularRcvd;
@end
