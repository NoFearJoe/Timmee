//
//  ObjectiveCTryCatch.m
//  Workset
//
//  Created by Илья Харабет on 20/04/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

#import "ObjectiveCTryCatch.h"

@implementation SwiftTryCatch

+ (void)try:(__attribute__((noescape)) void(^ _Nullable)(void)) try
      catch:(__attribute__((noescape)) void(^ _Nullable)(NSException*exception)) catch
    finally:(__attribute__((noescape)) void(^ _Nullable)(void)) finally {
    @try {
        if (try != NULL) try();
    }
    @catch (NSException *exception) {
        if (catch != NULL) catch(exception);
    }
    @finally {
        if (finally != NULL) finally();
    }
}

@end
