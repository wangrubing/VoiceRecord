//
//  VRListControllerTableViewController.m
//  VoiceRecord
//
//  Created by 王茹冰 on 16/6/13.
//  Copyright © 2016年 王茹冰. All rights reserved.
//

#import "VRListController.h"
#import "WRBVoiceRecordManager.h"
#import "WRBAlertViewTool.h"

@interface VRListController ()
@property (nonatomic, strong) NSArray *voiceArray;
@end

@implementation VRListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self configNav];
    [[WRBVoiceRecordManager sharedInstance] playFinishedBlock:^{
        [[WRBAlertViewTool sharedInstance] showAlertViewInViewController:self title:@"播放完毕！" message:nil operation:nil];
    }];
}

- (void)configNav
{
    [self setTitle:@"语音列表"];
    UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseButton.frame = CGRectMake(0, 0, 50, 36);
    [pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    [pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pauseButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [pauseButton addTarget:self action:@selector(pauseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:pauseButton];
}

- (void)pauseButtonTouched:(UIButton *)sender
{
    WRBVoiceRecordManager *manager = [WRBVoiceRecordManager sharedInstance];
    if (manager.audioPlayer.isPlaying) {
        [manager.audioPlayer pause];
        [sender setTitle:@"播放" forState:UIControlStateNormal];
    } else {
        [manager.audioPlayer play];
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
    }
}

- (void)loadData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"list.txt"];
    self.voiceArray = [NSArray arrayWithContentsOfFile:path];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.voiceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row < self.voiceArray.count) {
        cell.textLabel.text = self.voiceArray[indexPath.row];
    } else {
        cell.textLabel.text = @"";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.voiceArray.count) {
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *fileName = self.voiceArray[indexPath.row];
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        [[WRBVoiceRecordManager sharedInstance] playWithPath:filePath];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
