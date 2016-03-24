//
//  RegularExpressionVC.m
//  obj-Practise
//
//  Created by Bui Chung on 2/22/16.
//  Copyright © 2016 Bui Chung. All rights reserved.
//

#import "RegularExpressionVC.h"
#define kEmailRegex @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
#define kNumberRegex @"^(?:|0|[1-9]\\d*)(?:\\.\\d*)?$"
#define kTagsRegex  @"[A-Z0-9a-z._+-, ]"

@interface RegularExpressionVC ()

@end

@implementation RegularExpressionVC

#pragma mark - Cycle life

- (instancetype)init {
    self = [super initWithNibName:@"RegularExpressionVC" bundle:nil];
    if (self) {
        
    }
    return self;
}

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
    self.title = kCellTitleAboutRegularExpression;
    NSString *string = @"bcc; ";
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kTagsRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string
                                                        options:0
                                                          range:NSMakeRange(0, [string length])];
    if (numberOfMatches > 0) {
        NSLog(@"Has searched %lu place",(unsigned long)numberOfMatches);
    }
}

#pragma mark - IB Outlet Action

#pragma mark -

@end
