# Drive plotting
My attempts to keep it modest.

## Findings while testing

### Default throughput bottleneck
Ok, so I totally overestimated how much data is being pushed to the plot device. By default gp3 has a throughput of 125 MB/s. Now, it is said that 16TiB is written for 1 k-32 plot. And when I calculate the following 16TiB/125Mb/60/60 (google will say) it will take 39 HOURS(!) to puch all that data...

Public keys:
Farmer: 83f5137b261c8def0cb4cb93abeca0c31367d1dca904b16738714c9eccf2e114460a6552f1ca788bf6703ee732ca094d
Pool: a835f8c7ad6055b5a7cf4a316136a02b190e148c594b614782728d9e008bd5e0a5f336754ffd4af13784f2955a5618ed

First try: t4g.medium
Expected cost: $3.47 per plot of 12 hours
Purpose tag: t4g.modest
Actual cost: 