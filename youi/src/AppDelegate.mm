#if defined(YI_IOS) || defined(YI_TVOS)

#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import <Bugsnag/Bugsnag.h>

#define LOG_TAG "AppDelegate"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    [Bugsnag startBugsnagWithApiKey:@"ec866230dd7116c94845586bafc31326"];

    [Bugsnag notifyError:[NSError errorWithDomain:@"tv.youi" code:408 userInfo:nil]];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end

#endif
