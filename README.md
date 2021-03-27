# Tropical Chia
Not the drink, just a Chia plotter in the Amazon (Web Services).

So here is the obligatory tale of woe that is my live. You know, just like any other recipe you find on the internet. I had some credit with the wrong people (AWS), I had to kill (some hardware), and my redemption arc (of plotting and farming Chia) was spectacular.

All jokes aside. I noticed that I was not plotting fast (enough) on my own PC. And I still had some AWS credits... Let's do some research!

Next up are some explanations. If you want to skip to the good stuff, [click here](#The-Good-Stuff)
## What is Chia?
If you found your way here through the wilds of the internet, not knowing what Chia is, allow me to explain it briefly:

Chia is a cryptocurency. Basically it uses Proof of Capacity for its consensus protocol. This means you are mining with disk space instead of hashing power.  
However, unlike other PoC coins there is also a Proof of Time concept run by "timelords". The Chia team calls it a Proof of SpaceTime.
You can read it all over at [their project page](https://chia.net), or [their github](https://github.com/Chia-Network/chia-blockchain).

## What is plotting
Plotting is the act of precalculating your hashes and storing them in a lookup table. This takes a considerable amount of time by design where your storage hardware is a critical factor in the plotting time. But when it is done you got a large file of hashes that you can use 'forever' (until requirements change on mainnet). Mining that file (farming) can be done with light hardware like a rapberry pi. The Chia team even provides install instruction on their [GitHub wiki](https://github.com/Chia-Network/chia-blockchain/wiki/Raspberry-Pi).

## Plotting hardware
You could use your current PC to plot. However, you can expect to be taking 10-12 hours to make 1 k-32 plot on a decent gaming rig. There is a [spreadsheet](https://docs.google.com/spreadsheets/d/14Iw5drdvNJuKTSh6CQpTwnMM5855MQ46/edit#gid=480571772) maintained by the community where you can see some of the setups created, and their speeds.

Due to the nature of plotting Chia you are mostly dependend on your memory and storage specs. And the cloud should be able to provide [infinite](./MemPlotting/README.md) of both. 

If you decide to plot yourself, and want to use a SSD, it is advised to use enterprise grade SSD's. The plotting process can write up to 1.8TiB in data per k-32 plot. This will devour your consumer grade SSD (it almost did mine).

## Requirements
We know that a k-32 plot (the minimum plot size eligable for farming) takes about 332 GiB (356.5 GB). It's final size being 101.4 GiB (108.9 GB). We can also use multiple 

You also need some RAM to compute the hashes. The Chia team [provided](https://www.chia.net/2021/02/22/plotting-basics.html#good-assumptions) a nice chart with values:
| RAM MiB:    | Minimum | Medium | Maximum |
| ----------- | ------- | ------ | ------- |
| Bitfield    | 2500    | 3400   | 6750    |
| No Bitfield | 1400    | 3500   | 3990    |

Of note: [Bitfield](https://en.wikipedia.org/wiki/Bit_field) is used to lower the amount of writes needed to plot and can speed up HD plotting. If you are using SSD's (which aren't yours) this wil actually slow down plotting. So, we will be useing the No BitField values.

You can use multiple threads for plotting. Standard is 2, but you can go up to any number. It is said that [going higher than 4 has diminishing returns]([provided](https://www.chia.net/2021/02/22/plotting-basics.html#good-assumptions) ). We can always experiment with [bigger boxes](./MemPlotting/README.md) later, let's look at the recommended specs first. 

To truly optimize your plotting speed staggered/parallel plotting is required. For now I will just focus on sequential plotting.

So with all that the following will suffice:
 - 4 vCPUs
 - 4 GiB Memory
 - 340 GiB of SSD (gp2 or gp3)
 For final storage I will use S3 as I will be farming on a local raspberry pi.

## Expected Cloud Costs
With the requirement known, we can calculate expected costs of plotting. I will try and find the cheapest options available. Keyword 'try'. AWS pricing is a complex thing where every instance has different regional pricing, AND different spot pricing. Luckily there are [people](https://simonpbriggs.co.uk/) out there that can [help](https://simonpbriggs.co.uk/amazonec2/).

First up is instance type:  
With AWS we got a problem. There isn't a 4 GiB instance with 4 vCPUs and we don't have custom options. Either we need to downgrade to a 2 vCPU instance, or upgrade to 8 GiB of memory. For now, I will go with a 2 vCPU instance. As 2 threads is recommended. But I will for sure revisit this later.  
Of these instances the the t4g.medium would suffice. It is a good all-round burster with good pricing. And with spot instance we can even get cheaper. Normally it is $0.0224 per Hour, on the moment of writing this instance is $0.0067 per Hour (in ap-south-1).
Worst case scenario (being 12 hours), it will cost $0.2688 on-demand and $0.0804 spot.

Secondly, storage:  
We gotta need some serious disk storage. At first it looked like I needed to calculate if either gp2 or gp3 is cheaper/better. But it seems gp3 is pretty much [always cheaper](https://cloudwiry.com/ebs-gp3-vs-gp2-pricing-comparison/). Plus, we get to add extra iops without paying for a bigger drive. Io2 might also be an option, but I don't have much experience with io-storage. Let's just add it to the todo list of revisits.
Let's create a gp3 drive with gp2 equivelant performance: 1020 IOPS / 250 MB/s. Which will be $32.20/GB*Months. Calculating that back to 12 hours (with 720 hour months) will be $0.537 per plot.

The final plot destination will be S3. As it will only be there for a very short time we could just neglect the costs of this. But, should you not be able to download the plot imediately you will pay about $0.025/GB*Month. So about $0.09 per plot per day.

Finally, data transfer:  
To get data out of AWS, you have to pay per GB. $0.0245 per GB for the first 10TB. One plot is 108.9GB. And with a trusty calculator we got $2.67 per plot.
Now, we do need to prevent 'hidden' outbound data. So we need a s3-service gateway just to make sure we aren't routing completed plots over the internet and incuring costs.

Resulting in (on-demand):  
Instance (t4g.medium): $0.2688  
Storage: $0.537  
Data out: $2.67
Making it: $3.47 per plot of 12 hours...

Now, this is the bare minimum. We could go way crazier. But for now, let's keep it basic.

All of this are theoreticalls. I will come back when I got some actual figures after my experiments. You can find them inside the respective folders.

## The Good Stuff
So with all the boring stuff out of the way. Let's crack our knuckles and start writing code(-ish). As this is also an excersize for me, I aim to create deploy ready packages. This is my good stuff. If you ain't into that, well look into the folders to see the products of my labour.

https://github.com/ericaltendorf/plotman