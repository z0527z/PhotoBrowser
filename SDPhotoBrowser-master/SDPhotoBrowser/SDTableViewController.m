//
//  SDTableViewController.m
//  SDPhotoBrowser
//
//  Created by aier on 15-2-4.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

#import "SDTableViewController.h"
#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"


@interface SDTableViewController ()

@property (nonatomic, strong) NSArray *srcStringArray;

@end

@implementation SDTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 200;
    
    self.title = @"图片浏览(GSD)";
    
    _srcStringArray = @[@"http://ww4.sinaimg.cn/thumbnail/e940e6d7gw1eptkxevyvbj20bh2w7tsn.jpg",
                        @"http://ww2.sinaimg.cn/thumbnail/67307b53jw1epqq3bmwr6j20c80axmy5.jpg",
                        @"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg",
                        @"http://ww2.sinaimg.cn/thumbnail/642beb18gw1ep3629gfm0g206o050b2a.gif",
                        @"http://ww4.sinaimg.cn/thumbnail/9e9cb0c9jw1ep7nlyu8waj20c80kptae.jpg",
                        @"http://ww3.sinaimg.cn/thumbnail/413420fbjw1eq8nb3dwm1j20ez0540tn.jpg",
                        @"http://ww3.sinaimg.cn/thumbnail/a7c49da7jw1eq90t7ixhyj20c80bq755.jpg",
                        @"http://ww4.sinaimg.cn/thumbnail/a7c49da7gw1eq7mi96x00g20av05n1l0.gif",
                        @"http://ww2.sinaimg.cn/thumbnail/a7c49da7gw1eq7qgewqitj20c10lidhi.jpg"];
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    SDPhotoGroup *photoGroup = [[SDPhotoGroup alloc] init];
    
    NSMutableArray *temp = [NSMutableArray array];
    [_srcStringArray enumerateObjectsUsingBlock:^(NSString *src, NSUInteger idx, BOOL *stop) {
        SDPhotoItem *item = [[SDPhotoItem alloc] init];
        item.thumbnail_pic = src;
        [temp addObject:item];
    }];
    
    photoGroup.photoItemArray = [temp copy];
    [cell.contentView addSubview:photoGroup];
    
    return cell;
}


@end
