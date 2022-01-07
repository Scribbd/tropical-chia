# Drive plotting
My attempts to keep it modest.

## Findings while testing

### Default throughput bottleneck
Ok, so I totally overestimated how much data is being pushed to the plot device. By default gp3 has a throughput of 125 MB/s. Now, it is said that 16TiB is written for 1 k-32 plot. And when I calculate the following 16TiB/125Mb/60/60 (google will say) it will take 39 HOURS(!) to push all that data... And that is without the calculation time. So, a better drive is very much needed.

So what are the option?

Gp3 allows provisioning of extra throughput up to 1000MiB/s. It costs $0.0456/provisioned MB/s-month over 125MiB/s. So to max it out it will take: $39.90 extra per month. Going back to per plot ($39.90/730*12=) $0.61 cents extra.  
Maxing out the IOPs will also increase the cost. To total of $127.02 per month or $2.09 per plot of 12 hours.  
Per IOP provisioned .25MB/s can also be provisioned. Meaning that we could go down to 4000 IOPS making the whole $79.80 or $1.31 per 12 hour plot

Io2 is another option which also allows for 1000MiB/s, and scales with IOPS provisioned. Calculating pricing is quite the hassle. So I am refering to calculator.aws to figure out how much it will cost and... $3578.50 ouch. Bringing it down to plots gets us: $58.82 for a 12 hour plot.
If the plotting allows it we could cheapen it up by using 256KiB IO sizes bringing the max speed down to 500 MiB/s at 2000 IOPS: $206.66 or $3.40 per 12 hour plot.

Io2 Block Express is a very compelling. On the moment of writing this, io2 block express is in preview. Why it is interesting: It can get throughput speeds up to 4000MiB/s.
We can crank the price even higher... as the pricing model does not change. Except, when going for an io size of 256KiB gets you the 4,000MiB/s. So, same price bigger performance if plotting allows it.

And last. The st1 class hard disks. They provide a maximum of 500 Mib/s on 1Mib chunky IO sizes. They are cheap but require 12.5TB of storage to be at maximum speed all the time ($691.20 = $11.36 per 12 hour plot).  
It does allow bursting to that speed on lower sizes. We shall see how that fares the plotting process. At 2 TB the base is 80 Mib/s, but allows the max in burst. Bringing the cost down to $1.82 per 12 hour plot

Conclusion: It is expensive. Cheapest option is still the gp3 drive. If we assume that all plots will take 12 hours. 


Public keys:
Farmer: 83f5137b261c8def0cb4cb93abeca0c31367d1dca904b16738714c9eccf2e114460a6552f1ca788bf6703ee732ca094d
Pool: a835f8c7ad6055b5a7cf4a316136a02b190e148c594b614782728d9e008bd5e0a5f336754ffd4af13784f2955a5618ed

First try: t4g.medium
Expected cost: $3.47 per plot of 12 hours
Purpose tag: t4g.modest
Actual cost: DNF