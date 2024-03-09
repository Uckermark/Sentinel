#include <sys/types.h>
#include <dlfcn.h>
#include <unistd.h>
#import <spawn.h>

#include <stdio.h>
#include <mach/mach.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/pwr_mgt/IOPMLib.h>


int main(int argc, char *argv[]) {
   	setuid(0);
	setuid(0);
    setgid(0);
    setgid(0);

	extern char **environ;

    mach_port_t master = kIOMasterPortDefault;
    kern_return_t err = KERN_SUCCESS;
    io_service_t ref = MACH_PORT_NULL;

    ref = IORegistryEntryFromPath(kIOMasterPortDefault, "IOPower:/IOPowerConnection/IOPMrootDomain");
  
    if(IO_OBJECT_NULL == ref) {
        return KERN_FAILURE;
    }

    err = IORegistryEntrySetCFProperty(ref, CFSTR("System Boot Complete"), kCFBooleanTrue);

    ref = IOPMFindPowerManagement(master);
    if(IO_OBJECT_NULL == ref) {
        return KERN_FAILURE;
    }
    // Send the hibernate mach message to IOPowerManagement

    err = IOPMSleepSystem(ref);
  
    if(KERN_SUCCESS != err) {
        return KERN_FAILURE;
    }

    return err;
}
