# Communication Model

## Description:



### Aggregation Index Calculation

The calculation of the aggregation index is done following the directions of webpage ()

To find the size of n, as the square containing exactly the total number of patches in the simulation or the next smallest square corresponding.
n being the length of the side of that square.
The search for the value of n is implemented in the followingg way:

We loop over all values of i from 0 to the total number of patches
    
The stopping condition is:	sqrt(tot - i) % 1  ==  0

This condition insure obtaining the next smallest square encompassing the largest proportion of total number of patches
