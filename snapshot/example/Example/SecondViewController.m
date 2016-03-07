//
//  SecondViewController.m
//  Example
//
//  Created by Felix Krause on 10.11.14.
//  Copyright (c) 2015 Felix Krause. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *title = [[NSUserDefaults standardUserDefaults] stringForKey:@"userTitle"];
    if (title) {
        self.titleLabel.text = title;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
