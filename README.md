# EM Factor

Original Ideas from Robeco: The alpha and beta of emerging markets equities [link](https://www.robeco.com/en-us/insights/2023/08/the-alpha-and-beta-of-emerging-markets-equities)

# Overview
The idea behind this comes from the work that was done at the Robeco team (link above). The posit that macroeconomic indicators that are commonly used in Emerging Markets are not as statistically significant as they are prevelant. They provide evidence as well as the necessary empirical studies to support their claim. Towards the latter of the research they present an interesting idea. That although growth with tends to be the main theme of emerging markets trading, a majority of their relative pricing can be attributed to value-related factors, which this repo will primarily look at

# Setup
In this case the setup compares the price ratio between one developed market index and the MSCI EM Index. The developed market indexes used are MSCI World Equity Index, Bloomberg Developed Market Equity Index, and the Russell 2,000 Index. The following statistics were collected with regards to those indices: price, P/B, P/E, and Dividend Yield. 
![image](https://github.com/diegodalvarez/EMFactor/assets/48641554/6891eb06-7eb9-4ebd-8a65-77c838f4081d)
Then get the following ratios
![image](https://github.com/diegodalvarez/EMFactor/assets/48641554/8edf4dde-8463-4f4e-8300-5852b97b03f3)
The next set up is running regressions
![image](https://github.com/diegodalvarez/EMFactor/assets/48641554/d31b07a2-d281-48b9-9e5e-fa5db693e9bb)

# Results
From the regression its somewhat evident that value related factor can explain price ratios between developed markets and emerging markets. With some outliers which may be mechanical errors or extreme events, most regressions look substantial. Noticably P/B tends to be the best factor. A consideration to make is that this model doesn't compare respective growth factors. That decision was made since this was a somewhat impromptu analysis, and the analysis isn't meant to oppose the idea that growth is irrelevant but rather show that value factors are at play. Like most factor-based asset manager the most likely approach would be to use blended factors to capture both premias.

# Future Work
The next work would be to backtest two strategies. Quintile (then beta-neutral) Long-Short portfolio of growth vs. value. Then analyze performance, alphas and betas.
