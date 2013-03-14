//
//  ViewController.m
//  DataUsage
//
//  Created by Praveen Jha on 12/03/13.
//  Copyright (c) 2013 Praveen Jha. All rights reserved.
//

#import "ViewController.h"
#include <arpa/inet.h> 
#include <net/if.h> 
#include <ifaddrs.h> 
#include <net/if_dl.h>
#import <sys/sysctl.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startMonitoring) userInfo:nil repeats:YES];
    [self startMonitoring];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) startMonitoring
{
    NSArray *data = [self getDataCounters];
    if ([data count]>=4)
    {
        self.wifiSent.text = [data[0] stringValue];
        self.wifiRcvd.text = [data[1] stringValue];
        self.cellularSent.text = [data[2] stringValue];
        self.cellularRcvd.text = [data[3] stringValue];
    }
//    NSLog(@"Running apps:%@",[self runningProcesses]);
}

/*
 The thing is that pdp_ip0 is one of interfaces, all pdpXXX are WWAN interfaces 
 dedicated to different functions, voicemail, general networking interface.

 i read in apple forum that : The OS does not keep network statistics on a 
 process-by-process basis. As such, there's no exact solution to this problem. 
 You can, however, get network statistics for each network interface.

 In general en0 is your Wi-Fi interface and pdp_ip0 is your WWAN interface.

 There is no good way to get information wifi/cellular network data since, 
 particular date-time!

 data statistic (ifa_data->ifi_obytes and ifa_data->ifi_ibytes) are stored 
 from previos device reboot.

 i don't know why, but ifi_opackets and ifi_ipackets are shown just for lo0 
 (i think its main interface ).

 yes. Then device is conected via WiFi and doesn't use internet if_iobytes 
 values still come becouse this metod provides nerwork bytes exchanges and not 
 just internet .
 */
- (NSArray *)getDataCounters
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;

    int WiFiSent = 0;
    int WiFiReceived = 0;
    int WWANSent = 0;
    int WWANReceived = 0;

    NSString *name=[[NSString alloc]init];

    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN

            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                    NSLog(@"WiFiSent %d ==%d",WiFiSent,networkStatisc->ifi_obytes);
                    NSLog(@"WiFiReceived %d ==%d",WiFiReceived,networkStatisc->ifi_ibytes);
                }

                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                    NSLog(@"WWANSent %d ==%d",WWANSent,networkStatisc->ifi_obytes);
                    NSLog(@"WWANReceived %d ==%d",WWANReceived,networkStatisc->ifi_ibytes);
                }
            }

            cursor = cursor->ifa_next;
        }

        freeifaddrs(addrs);
    }

    return [NSArray arrayWithObjects:[NSNumber numberWithInt:WiFiSent], [NSNumber numberWithInt:WiFiReceived],[NSNumber numberWithInt:WWANSent],[NSNumber numberWithInt:WWANReceived], nil];
}

- (NSArray *)runningProcesses {

    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;

    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);

    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;

    do {

        size += size / 10;
        newprocess = realloc(process, size);

        if (!newprocess){

            if (process){
                free(process);
            }

            return nil;
        }

        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);

    } while (st == -1 && errno == ENOMEM);

    if (st == 0){

        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = size / sizeof(struct kinfo_proc);

            if (nprocess){

                NSMutableArray * array = [[NSMutableArray alloc] init];

                for (int i = nprocess - 1; i >= 0; i--){

                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    NSString * processState = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_wmesg];
                    NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName,processState, nil]
                                                                        forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName",@"ProcessState", nil]];
//                    [processID release];
//                    [processName release];
                    [array addObject:dict];
//                    [dict release];
                }
                
                free(process);
                return array; //autorelease];
            }
        }
    }
    
    return nil;
}

@end
