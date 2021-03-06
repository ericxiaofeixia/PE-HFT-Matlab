% Portfolio Settings
%
%
% Usage
%
% portfolio_settings(portfolio, portfolioMetricsMode, windowLength, holdingPeriodsOnly, shortSalesMode, jumpModel, noiseModel, nonGaussianModel,factorModel,resultsSamplingInterval,inputSamplingInterval,timeScale)
%
% portfolio
%     Portfolio object created using portfolio_create( ) function
%
% portfolioMetricsMode
%     One of the two modes for collecting portfolio metrics could be used:
%     'portfolio' - Risk and performance metrics are computed based on the history of position rebalancing (see windowLength parameter). Should be used to backtest and compare intraday strategies of different frequency and style.
%     'price' - Metrics are computed for a buy-and-hold strategy with static portfolio allocation.
%     Defaults to 'portfolio'.
%
% windowLength
%     Rolling window length for metric estimations and for tracking position rebalancing history. Available interval values are: "Xs" - seconds, "Xm" - minutes, "Xh" - hours, "Xd" - trading days (6.5 hours in a trading day), "Xw" - weeks (5 trading days in 1 week), "Xmo" - month (21 trading day in 1 month), "Xy" - years (256 trading days in 1 year), "all" - all observations are used. Default value is "1d" - one trading day.
%
% holdingPeriodsOnly
%     Used when portfolioMetricsMode = "portfolio". Defaults to true, which means that trading strategy risk and performance metrics will be scaled to include intervals when trading strategy did not have market exposure. When true, trading strategy metrics are scaled based on actual holding intervals when there was exposure to the market.
%
% shortSalesMode
%	  Used to specify how position weights are computed. Available modes are: "lintner" - the sum of absolute weights is equal to 1 (Lintner assumption), "markowitz" - the sum of weights must equal to 1 (Markowitz assumption). Defaults to "lintner", which implies that the sum of absolute weights is used to normalize investment weights.
%
% jumpsModel
%	Used to select jump filtering mode when computing return statistics. Available modes are: "none" - price jumps are not filtered anywhere, "moments" - price jumps are filtered only when computing return moments (i.e. for expected return, variance, skewness, kurtosis and derived metrics), "all" - price jumps are filtered from computed returns, prices and all return metrics. Defaults to "moments", which implies that only return moments and related metrics would be using jump-filtered returns in their calculations.
%
% noiseModel
%     Used to enable mirostructure noise filtering of distribution returns.  Defaults to true, which implies that microstructure effects are modeled and resulting HF noise is removed from metric calculations.
%
% fractalPriceModel
%     Used to enable mono-fractal price assumptions (fGBM) when time scaling return moments.  Defaults to TRUE, which implies that computed Hurst exponent is used to scale return moments. When FALSE, price is assumed to follow regular GBM with Hurst exponent = 0.5.
%
% densityModel
%     Used to select density approximation model of return distribution. Available models are: "GLD" - Generalized Lambda Distribution, "CORNER_FISHER" - Corner-Fisher approximation, "NORMAL" - Gaussian distribution. Defaults to "GLD", which would fit a very broad range of distribution shapes.
%
% factorModel
%    Used to select factor model for computing portfolio metrics. Available models are: "sim" - portfolio metrics are computed using the Single Index Model, "direct" - portfolio metrics are computed using portfolio value itself. Defaults to "sim", which implies that the Single Index Model is used to compute portfolio metrics.
%
% driftTerm
%    Used to enable drift term (expected return) when computing probability density approximation and related metrics (e.g. CVaR, Omega Ratio, etc.). Defaults to FALSE, which implies that distribution is centered around zero return.
%
% resultsNAFilter
%    Used to enable filtering of NA values in computed results. Defaults to TRUE, which implies that output results have all NA values removed.
%
% resultsSamplingInterval
%     Interval to be used for sampling computed results before returning them to the caller. Available interval values are: "Xs" - seconds, "Xm" - minutes, "Xh" - hours, "Xd" - trading days (6.5 hours in a trading day), "Xw" - weeks (5 trading days in 1 week), "Xmo" - month (21 trading day in 1 month), "Xy" - years (256 trading days in 1 year), "last" - latest value in a series is returned, "none" - no sampling. Large sampling interval would produce smaller vector of results and would require less time spent on data transfer. Default value of "1s" indicates that data is returned for every second during trading hours.
%
% inputSamplingInterval
%	  Interval to be used as a minimum step for sampling input prices. Available interval values are: "Xs" - seconds, "Xm" - minutes, "Xh" - hours, "Xd" - trading days (6.5 hours in a trading day), "Xw" - weeks (5 trading days in 1 week), "Xmo" - month (21 trading day in 1 month), "Xy" - years (256 trading days in 1 year), "none" - no sampling. Default value is "none", which indicates that no sampling is applied.
%
% timeScale
% 	  Interval to be used for scaling return distribution statistics and producing metrics forecasts at different horizons. Available interval values are: "Xs" - seconds, "Xm" - minutes, "Xh" - hours, "Xd" - trading days (6.5 hours in a trading day), "Xw" - weeks (5 trading days in 1 week), "Xmo" - month (21 trading day in 1 month), "Xy" - years (256 trading days in 1 year), "all" - actual interval specified in during portfolio creation. Default value is "1d" - one trading day.
%
% txnCostPerShare
% 	  Amount of transaction costs per share. Defaults to 0.
%
% txnCostFixed
% 	  Amount of transaction costs per transaction. Defaults to 0.
%
%
% Return Value
%
% Void
%
% Note
%
% PortfolioEffect - Matlab Interface to Quant API
%
% Copyright (C) 2010 - 2015 Snowfall Systems, Inc.
%
%
% Examples
%
% data_goog=importdata('data_goog.mat');
% data_aapl=importdata('data_aapl.mat');
% data_spy=importdata('data_spy.mat');
% portfolioExample=portfolio_create('priceDataIx',data_spy);
% portfolio_addPosition(portfolioExample,'GOOG',100,'priceData',data_goog);
% portfolio_addPosition(portfolioExample,'AAPL',300,'priceData',data_aapl);
% portfolio_addPosition(portfolioExample,'SPY',150,'priceData',data_spy);
% portfolio_settings(portfolioExample,'portfolioMetricsMode','price','windowLength','3600s');
% portfolioExample
%
% dateStart = '2014-11-17 09:30:00';
% dateEnd = '2014-11-19 16:00:00';
% portfolioExample=portfolio_create('index','SPY','fromTime',dateStart ,'toTime',dateEnd );
% portfolio_addPosition(portfolioExample,'AAPL',100);
% portfolio_addPosition(portfolioExample,'C',300);
% portfolio_addPosition(portfolioExample,'GOOG',150);
% portfolio_settings(portfolioExample,'portfolioMetricsMode','price','windowLength','3600s');
% portfolioExample
function portfolio_settings(portfolio,varargin)
if ~util_validateConnection()
    return;
end
if isstruct(varargin{1})
    p=varargin{1};
else
    p=struct(varargin{:});
end
names=fieldnames(p);
for i = 1:length(names)
    name=char(names(i));
    switch name
        case 'portfolioMetricsMode'
            portfolio.java.setParam('portfolioMetricsMode',p.portfolioMetricsMode);
        case 'windowLength'
            portfolio.java.setParam('windowLength',p.windowLength);
        case 'holdingPeriodsOnly'
            portfolio.java.setParam('isHoldingPeriodEnabled',p.holdingPeriodsOnly);
        case 'shortSalesMode'
            portfolio.java.setParam('shortSalesMode',p.shortSalesMode);
        case 'jumpsModel'
            portfolio.java.setParam('jumpsModel',p.jumpsModel);
        case 'noiseModel'
            portfolio.java.setParam('isNoiseModelEnabled',p.noiseModel);
        case 'fractalPriceModel'
            portfolio.java.setParam('isFractalPriceModelEnabled',p.fractalPriceModel);
        case 'factorModel'
            portfolio.java.setParam('factorModel',p.factorModel);
        case 'densityModel'
            portfolio.java.setParam('densityApproxModel',p.densityModel);
        case 'driftTerm'
            portfolio.java.setParam('isDriftEnabled',p.driftTerm);
        case 'resultsNAFilter'
            portfolio.java.setNaNFiltered(logical(str2num(p.resultsNAFilter)));
        case 'resultsSamplingInterval'
            portfolio.java.setParam('samplingInterval',p.resultsSamplingInterval);
        case 'inputSamplingInterval'
            portfolio.java.setParam('priceSamplingInterval',p.inputSamplingInterval);
        case 'timeScale'
            portfolio.java.setParam('timeScale',p.timeScale);
        case 'txnCostPerShare'
            portfolio.java.setParam('txnCostPerShare',num2str(p.txnCostPerShare));
        case 'txnCostFixed'
            portfolio.java.setParam('txnCostFixed',num2str(p.txnCostFixed));
        otherwise
            error('Wront setting name');
    end
end
end
