//
//  ViewController.m
//  obj-Practise
//
//  Created by Bui Chung on 2/22/16.
//  Copyright © 2016 Bui Chung. All rights reserved.
//

#import "NaviagationVC.h"

typedef enum  {
    ePractiseInit = 0,
    ePractiseAboutRegularExpression,
} ePractise;

@interface NaviagationVC () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableContent;
@property (strong, nonatomic) NSArray *listSectionContent;

@end

@implementation NaviagationVC

#pragma mark - Cycle life

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

#pragma mark - Private Methods
- (void) initView {
    _listSectionContent = @[
                            kCellTitleAboutRegularExpression,
                            kCellTitleAboutAVFoundation
                            ];
}

#pragma mark - IB Outlet Action

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_listSectionContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifyTableviewCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIdentifyTableviewCell];
    }
    
    [cell.textLabel setText:[_listSectionContent objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *objIndex = [_listSectionContent objectAtIndex:indexPath.row];
    if ([objIndex isEqualToString:kCellTitleAboutRegularExpression]) {
        RegularExpressionVC *vc = [[RegularExpressionVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([objIndex isEqualToString:kCellTitleAboutAVFoundation]) {
        ShowingVideoListVC *vc = [[ShowingVideoListVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
