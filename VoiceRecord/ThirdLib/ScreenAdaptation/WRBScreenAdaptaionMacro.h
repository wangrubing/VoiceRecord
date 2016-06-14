//
//  WRBScreenAdaptaionMacro.h
//  ScreenAdaptation
//
//  Created by 王茹冰 on 16/5/13.
//  Copyright © 2016年 王茹冰. All rights reserved.
//

#ifndef WRBScreenAdaptaionMacro_h
#define WRBScreenAdaptaionMacro_h

#define AdaptaionFlag
#define autoSizeScale [[UIScreen mainScreen] bounds].size.height/480
#ifdef AdaptaionFlag
    #define CGRectMake CGRectMakeEx
    #define CGSizeMake CGSizeMakeEx
    #define widthEx widthEx
    #define heightEx heightEx
#else
    #define CGRectMake CGRectMake
    #define CGSizeMake CGSizeMake
    #define widthEx
    #define heightEx
#endif

#endif
