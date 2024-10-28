import argparse
import gzip
import sys
import time
import random
import datetime
import numpy
from faker import Faker

print("Script started")

class switch(object):
    def __init__(self, value):
        self.value = value
        self.fall = False

    def __iter__(self):
        yield self.match
        raise StopIteration

    def match(self, *args):
        if self.fall or not args:
            return True
        elif self.value in args:
            self.fall = True
            return True
        else:
            return False

# Argument parser for input options
parser = argparse.ArgumentParser(__file__, description="Fake Apache Log Generator")
parser.add_argument("--output", "-o", dest='output_type', help="Write to a Log file, a gzip file or to STDOUT", choices=['LOG','GZ','CONSOLE'])
parser.add_argument("--log-format", "-l", dest='log_format', help="Log format, Common or Extended Log Format ", choices=['CLF','ELF'], default="ELF")
parser.add_argument("--num", "-n", dest='num_lines', help="Number of lines to generate (0 for infinite)", type=int, default=100)
parser.add_argument("--prefix", "-p", dest='file_prefix', help="Prefix the output file name", type=str)
parser.add_argument("--sleep", "-s", help="Sleep this long between lines (in seconds)", default=0.0, type=float)

args = parser.parse_args()

log_lines = args.num_lines
file_prefix = args.file_prefix
output_type = args.output_type
log_format = args.log_format

faker = Faker()

timestr = time.strftime("%Y%m%d-%H%M%S")

outFileName = 'access_log_'+timestr+'.log' if not file_prefix else file_prefix+'_access_log_'+timestr+'.log'

for case in switch(output_type):
    if case('LOG'):
        f = open(outFileName, 'w')
        break
    if case('GZ'):
        f = gzip.open(outFileName+'.gz', 'wt')
        break
    if case('CONSOLE'): 
        f = sys.stdout
    if case():  
        f = sys.stdout

response = ["200", "404", "500", "301"]
verb = ["GET", "POST", "DELETE", "PUT"]
resources = ["/list", "/wp-content", "/wp-admin", "/explore", "/search/tag/list", "/app/main/posts", "/posts/posts/explore", "/apps/cart.jsp?appID="]
ualist = [faker.firefox, faker.chrome, faker.safari, faker.internet_explorer, faker.opera]

# Choose a random year and month for the logs
year = 2024
month = random.randint(1, 12)

# Get the number of days in the chosen month
if month == 12:
    next_month = 1
    next_year = year + 1
else:
    next_month = month + 1
    next_year = year

# Get the number of days in the chosen month
last_day_of_month = (datetime.datetime(next_year, next_month, 1) - datetime.timedelta(days=1)).day

# Generate random datetimes within the chosen month for 100 entries
random_dates = []
for _ in range(100):
    random_day = random.randint(1, last_day_of_month)
    random_hour = random.randint(0, 23)
    random_minute = random.randint(0, 59)
    random_second = random.randint(0, 59)
    
    log_time = datetime.datetime(year, month, random_day, random_hour, random_minute, random_second)
    random_dates.append(log_time)

# Sort the random dates to simulate a more natural log flow
random_dates.sort()

# Total entries to generate
entries_generated = 0

while entries_generated < 100:
    log_time = random_dates[entries_generated]
    
    ip = faker.ipv4()
    dt = log_time.strftime('%d/%b/%Y:%H:%M:%S')
    tz = datetime.datetime.now().strftime('%z')
    vrb = numpy.random.choice(verb, p=[0.6, 0.1, 0.1, 0.2])
    
    uri = random.choice(resources)
    if uri.find("apps") > 0:
        uri += str(random.randint(1000, 10000))
    
    resp = numpy.random.choice(response, p=[0.9, 0.04, 0.02, 0.04])
    byt = int(random.gauss(5000, 50))
    referer = faker.uri()
    useragent = numpy.random.choice(ualist, p=[0.5, 0.3, 0.1, 0.05, 0.05])()

    # Write to log
    if log_format == "CLF":
        f.write('%s - - [%s %s] "%s %s HTTP/1.0" %s %s\n' % (ip, dt, tz, vrb, uri, resp, byt))
    elif log_format == "ELF": 
        f.write('%s - - [%s %s] "%s %s HTTP/1.0" %s %s "%s" "%s"\n' % (ip, dt, tz, vrb, uri, resp, byt, referer, useragent))

    f.flush()
    entries_generated += 1

    if args.sleep:
        time.sleep(args.sleep)

if output_type == 'LOG':
    f.close()
