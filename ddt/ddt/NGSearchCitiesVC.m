//
//  NGSearchCitiesVC.m
//  ddt
//
//  Created by wyg on 15/10/31.
//  Copyright © 2015年 Light. All rights reserved.
//

#import "NGSearchCitiesVC.h"
#import "ChineseToPinyin.h"

#define DefaultBgColor [UIColor colorWithRed:0.922 green:0.922 blue:0.922 alpha:1]

@interface NGSearchCitiesVC ()<UISearchBarDelegate,UISearchDisplayDelegate>
{
    NSArray *_allcity;
    NSArray *_searchResultArr;
    
    NSMutableArray *_allKey;
    NSMutableDictionary *_dataSourceDic;
    
}

@property(nonatomic,assign)BOOL isSearchStatus;
@property (weak, nonatomic) IBOutlet UISearchBar *searchCityBar;

@end

@implementation NGSearchCitiesVC

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage *_img = [UIImage imageNamed:@"bg_bar"];
    _img = [_img stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    [self.searchCityBar setBackgroundImage:_img];
//    self.searchCityBar.barTintColor = DefaultBgColor;
    
    [self initData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"check_city_list"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"check_city_list"];
}

-(void)initData
{
    self.title = @"选择城市";
    _allKey = [[NSMutableArray alloc]init];
    _dataSourceDic = [[NSMutableDictionary alloc]init];
    self.isSearchStatus= NO;
    _allcity = [NGXMLReader getAllCities];
    [self addDataWithArr:_allcity];
    [self.tableView reloadData];
}

-(void)awakeFromNib
{
    NSInteger _h = 3;
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setFrame:CGRectMake(0, 0, 20, 20)] ;
    [button setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal] ;
    [button setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateHighlighted] ;
    [button addTarget:self action:@selector(goback:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* item=[[UIBarButtonItem alloc]initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:item];
    [button setImageEdgeInsets:UIEdgeInsetsMake(_h,_h, _h, _h)] ;
    
//    self.tableView.backgroundView = nil;
//    self.tableView.backgroundColor = DefaultBgColor;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor darkGrayColor];
}

-(void)goback:(id)btn
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}


//按名字首字母分类
-(void)addDataWithArr :(NSArray*)arr
{
    for (int i=0; i < arr.count; i++) {
        NSDictionary *_dic = [arr objectAtIndex:i];
        NSString *_name = [_dic objectForKey:@"NAME"];
        NSString *_usrStr = [ChineseToPinyin pinyinFromChiniseString:_name];
        NSString *firstC =[_usrStr substringToIndex:1];
        NSArray *_keyArr = [_dataSourceDic allKeys];
        NSMutableArray *_tmpArr = nil;
        for (int m =0; m < _keyArr.count; m++) {
            NSString *_key = [_keyArr objectAtIndex:m];
            if ([firstC isEqualToString:_key]) {
                _tmpArr = [_dataSourceDic objectForKey:_key];
                [_tmpArr addObject:_dic];break;
            }
        }
        if (_tmpArr == nil) {
            _tmpArr  = [[NSMutableArray alloc]init];
            [_tmpArr addObject:_dic];
            [_dataSourceDic setObject:_tmpArr forKey:firstC];
        }
    }
    NSArray *allkey = [_dataSourceDic allKeys];
    _allKey = (NSMutableArray *)[allkey sortedArrayUsingSelector:@selector(compare:)];
}


-(NSArray *)searchDatawith:(NSString *)key
{
    if (!key ||(key && key.length < 1)) {
        return nil;
    }
    
    NSString *_strkey = [ChineseToPinyin pinyinFromChiniseString:key];
    NSMutableArray *_desarr =[[NSMutableArray alloc]init];
    [_allcity enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = (NSDictionary*)obj;
        NSString *_str2 = [ChineseToPinyin pinyinFromChiniseString:[dic objectForKey:@"NAME"]];
        if (dic && [_str2 rangeOfString:_strkey].location != NSNotFound) {
            [_desarr addObject:obj];
        }
    }];
    
    return _desarr;
}


#pragma mark -- UISearchBar delegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.isSearchStatus = YES;
    _searchResultArr = nil;
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
   _searchResultArr = [self searchDatawith:searchBar.text];
    if (_searchResultArr) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }

}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.isSearchStatus = NO;
    [self.tableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchResultArr = [self searchDatawith:searchBar.text];
    if (_searchResultArr) {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.isSearchStatus = NO;
    [self.tableView reloadData];
}

#pragma mark -- UITableView delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.isSearchStatus)
    {
        return 1;
    }
    return _allKey.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.isSearchStatus)
    {
        return _searchResultArr.count;
    }
    else
    {
        NSString *_str = [_allKey objectAtIndex:section];
        NSArray*_arr = [_dataSourceDic objectForKey:_str];
        return _arr.count;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.isSearchStatus)return nil;
    
    return [_allKey objectAtIndex:section];
}
-(NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(self.isSearchStatus)return nil;
    NSMutableArray *_arr = [[NSMutableArray alloc]initWithObjects:@"🔍", nil];
    [_arr addObjectsFromArray:_allKey];
    return _arr;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(self.isSearchStatus)return 0;
    if (index == 0) {
        return 0;
    }
    return index - 1;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSDictionary *_dic = nil;
    
    if (!self.isSearchStatus) {
        NSString *_str = [_allKey objectAtIndex:indexPath.section];
        NSArray*_arr = [_dataSourceDic objectForKey:_str];
        _dic = [_arr objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"NGCityCellID"];
    }
    else
    {
        _dic = [_searchResultArr objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"searchStatueCellId" ];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchStatueCellId"];
        }
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[_dic objectForKey:@"NAME"]];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *_dic = nil;
    if (self.isSearchStatus) {
        _dic = [_searchResultArr objectAtIndex:indexPath.row];
    }
    
    else
    {
        NSString *_str = [_allKey objectAtIndex:indexPath.section];
        NSArray*_arr = [_dataSourceDic objectForKey:_str];
        _dic = [_arr objectAtIndex:indexPath.row];
    }
    
    _popViewBackBlock(_dic);
    
    [self goback:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
