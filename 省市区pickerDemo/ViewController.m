
//
//  ViewController.m
//  省市区model
//
//  Created by 辛忠志 on 2017/7/10.
//  Copyright © 2017年 辛忠志. All rights reserved.
//

#import "ViewController.h"
#import "addressModel.h"
#import <MJExtension.h>
#import <SDAutoLayout.h>
@interface ViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>

{
    UILabel * label;
    NSMutableArray *shengArray;
    NSMutableArray *shiArray;
    NSMutableArray *xianArray;
    
    UIPickerView *myPickerView;
    
    NSMutableDictionary *chooseDic;
    NSString * allStr;/*省市区*/
    NSString * shengStr;/*省*/
    NSString * shiStr;/*市*/
    NSString * quStr;/*区*/
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    /*设置一个按钮 和 一个label进行赋值*/
    label= [[UILabel alloc]initWithFrame:CGRectMake(self.view.width/2-100, 50, 300, 50)];
    label.textColor= [UIColor grayColor];
    label.text = @"城市";
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.width/2, 120, 50, 50)];
    [btn setTitle:@"按钮" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor grayColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [self.view addSubview:label];
    
    /*把.json文件取出来 流形式的*/
    NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area" ofType:@"json"]];
    NSLog(@"%@",JSONData);
    
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@",dataDic);
    /*取出对象 里面第一层下面的son的数组*/
    NSMutableArray *dataArray=dataDic[@"result"][0][@"son"];
    //    NSLog(@"%@",dataArray);
    NSLog(@"%@",dataArray);
    shengArray=[NSMutableArray array];
    shiArray=[NSMutableArray array];
    xianArray=[NSMutableArray array];
    
    chooseDic=[NSMutableDictionary dictionary];
    
    //省数组 《字典转模型》
    shengArray=[addressModel mj_objectArrayWithKeyValuesArray:dataArray];
    //市数组，默认省数组第一个
    addressModel *model=shengArray[0];
    /*取出市里面的数组模型*/
    shiArray=[addressModel mj_objectArrayWithKeyValuesArray:model.son];
    //县数组，默认市数组第一个
    addressModel *model1=shiArray[0];
    /*取出县里面的数组模型*/
    xianArray=[addressModel mj_objectArrayWithKeyValuesArray:model1.son];
    addressModel *model2=xianArray[0];
    
    /*第一次就进行赋值 这样保证按钮点击之后 第一次是有值的*/
    allStr = [NSString stringWithFormat:@"%@-%@-%@",model.area_district,model1.area_district,model2.area_district];
    
    [chooseDic setValue:model.area_id forKey:@"sheng"];
    [chooseDic setValue:model.area_id forKey:@"shi"];
    [chooseDic setValue:model2.area_id forKey:@"xian"];
    
    
    // 选择框
    myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, self.view.width, 300)];
    // 显示选中框
    myPickerView.showsSelectionIndicator=YES;
    myPickerView.dataSource = self;
    myPickerView.delegate = self;
    [self.view addSubview:myPickerView];
}
-(void)btnClick{
    /*把选择好的地址进行赋值*/
    label.text = allStr;
}
#pragma Mark -- UIPickerViewDataSource
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return shengArray.count;
    }
    if (component==1) {
        return  shiArray.count;
    }
    if (component==2) {
        return xianArray.count;
    }
    
    return 0;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"选中%ld列---%ld行",(long)component,(long)row);
    if (component==0) {
        addressModel *model=shengArray[row];
        shiArray=[addressModel mj_objectArrayWithKeyValuesArray:model.son];
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:NO];
        //默认第一个
        addressModel *model1=shiArray[0];
        xianArray=[addressModel mj_objectArrayWithKeyValuesArray:model1.son];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:NO];
        addressModel *model2=xianArray[0];
        [chooseDic setValue:model.area_id forKey:@"sheng"];
        [chooseDic setValue:model1.area_id forKey:@"shi"];
        [chooseDic setValue:model2.area_id forKey:@"xian"];
        /*取出省字符串*/
        shengStr = model.area_district;
        shiStr = model1.area_district;
        quStr = model2.area_district;
        NSLog(@"%@",shengStr);
    }
    if (component==1) {
        addressModel *model1=shiArray[row];
        xianArray=[addressModel mj_objectArrayWithKeyValuesArray:model1.son];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:NO];
        addressModel *model2=xianArray[0];
        [chooseDic setValue:model1.area_id forKey:@"shi"];
        [chooseDic setValue:model2.area_id forKey:@"xian"];
        /*取出市字符串*/
        shiStr = model1.area_district;
        quStr = model2.area_district;
        NSLog(@"%@",shiStr);
    }
    if (component==2) {
        addressModel *model2=xianArray[row];
        [chooseDic setValue:model2.area_id forKey:@"xian"];
        /*取出区字符串*/
        quStr = model2.area_district;
        NSLog(@"%@",shengStr);
    }
    allStr = [NSString stringWithFormat:@"%@-%@-%@",shengStr,shiStr,quStr];
    NSLog(@"%@",chooseDic);
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component==0) {
        addressModel *model=shengArray[row];
        return model.area_district;
    }
    if (component==1) {
        addressModel *model=shiArray[row];
        return model.area_district;
    }
    if (component==2) {
        addressModel *model=xianArray[row];
        return model.area_district;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
