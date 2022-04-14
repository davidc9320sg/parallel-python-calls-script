from optparse import OptionParser
import time
import os

if __name__ == '__main__':
    # print PID of this script
    print('PID [{}]'.format(os.getpid()))

    parser = OptionParser()
    parser.add_option('-t', '--time', default=0, type=int, help='time to sleep in seconds')
    options, _ = parser.parse_args()

    # get option from arguments
    time_to_sleep = options.time
    if time_to_sleep == 0:
        # print cute remark
        print('I will sleep for {} seconds... Goodnight!'.format(time_to_sleep))
        # go to sleep
        for i in range(time_to_sleep):
            print('z', end='')
            time.sleep(1)
        # wake up
        print('\n*wakes up*')
    else:
        print('I will not got to sleep!')