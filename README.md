# QARMII_project

![HEC Lausanne](https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/HEC_Lausanne_logo.svg/200px-HEC_Lausanne_logo.svg.png)

```python
Quantitative Asset and Risk Management II
Prof. Fabio Alessandrini
HEC Lausanne
```

The aim of this project is to create a CTA style  cross asset trend-following strategy with two side objectives:

1. Avoid portfolio crash during momentum reversal.
2. Work in high correlation period. 

Indeed, academic research has shown that trend-following strategies tend to under-perform on high correlation regimes between assets. Moreover, obviously, when market drop or rebound fast, the signal may take a while to change sign and therefore perform poorly. 

### Signals

We used many signals in order to asses their performance.

1. Basic Signals

* Momentum with varying length, espcially 90 and 252 days as well as the return of the month 9 to 12. 

* Moving Average Crossover with varying length

2. Advanced Signals

* Weighted normalized EWMA Crossover (based on this article from [Baz. & al. 2015](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2695101))

* Singular Sprectal Analysis based signal

* Support Vector Machine classification based signal

##### Weighting schemes
We combined these signals with three different weighting schemes : 
* Equally Weighted
* Volatility Parity (inverse volatility, naive parity)
* Risk parity

##### Constant Volatility
We also used a leverage to attain a constant volatility, allowing the strategy to be more easily compared. 

### Implementation

The implementation is performed on matlab, for each strategies we created a function that takes on the data and parameters, and compute the signals, weights and leverage at each rebalancing.


### Author and Acknowledgment
* Maxime Borel

* Benjamin Souane

Thanks to [Fabio Alessandrini](https://wp.unil.ch/hecimpact/fr/people/fabio-alessandrini/) for the help and to Kevin Sheppard for the [amazing MFE toolbox](https://www.kevinsheppard.com/code/matlab/mfe-toolbox/).

