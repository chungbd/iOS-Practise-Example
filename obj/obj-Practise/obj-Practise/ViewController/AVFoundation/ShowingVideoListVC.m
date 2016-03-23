//
//  ShowingVideoListVC.m
//  obj-Practise
//
//  Created by Chung Bui Duc on 3/9/16.
//  Copyright © 2016 Bui Chung. All rights reserved.
//

#import "ShowingVideoListVC.h"
#import "VideoCell.h"

#define kCellIdentifier @"VideoCell"

@interface ShowingVideoListVC () <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSArray *listVideoModels;

@end

@implementation ShowingVideoListVC

#pragma mark - Life Cycle
- (instancetype) init {
//    if (self = [super initWithNibName:@"ShowingVideoListView" bundle:nil]) {
//        
//    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"AVFoundation" bundle:nil];
    self = [storyBoard instantiateViewControllerWithIdentifier:@"ShowingVideoListVC"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions
- (void) initView {
    
}

#pragma mark - Public Functions

#pragma mark - IB Action Outlet
- (IBAction)btn_TouchUpInside:(UIButton *)sender {
    
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (!cell) {
        NSLog(@"Cell is nil");
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_listVideoModels count];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
