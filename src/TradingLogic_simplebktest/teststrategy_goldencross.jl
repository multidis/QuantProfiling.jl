## Relatively simple trading strategy backtest
using TimeSeries
using TradingLogic

ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA_2.csv")
date_final = Date(2012,8,31)
ohlc_test = ohlc_BA[Date(1961,12,31):date_final]

ohlc_inds = (Symbol => Int64)[]
ohlc_inds[:open] = 1
ohlc_inds[:close] = 4

pfill = :open
mafast = 50
maslow = 200
targetqty = 100

function gcbktest()
  pnlfin, ddownmax, blotter = TradingLogic.runbacktest(
      ohlc_test, ohlc_inds, nothing, "", pfill, 0,
      TradingLogic.goldencrosstarget, targetqty,
      mafast, maslow)
  return abs(pnlfin - 2211.0) < 1e-3
end

# test PnL final
println(gcbktest())

# profiling
expr_run = parse("@time gcbktest()")
for i = 1:5
    eval(expr_run)
end

