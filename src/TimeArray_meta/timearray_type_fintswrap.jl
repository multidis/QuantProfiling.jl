## perofrmance comparison for different TimeArray type definitions
using TimeSeries
using MarketData, MarketTechnicals
using Reactive

# https://github.com/multidis/FinancialSeries.jl/blob/master/src/financialtimeseries.jl
using FinancialSeries

import FinancialSeries.percentchange
function percentchange{T,N, M}(ta::TimeArray{T,N, M}; method="simple") 
    logreturn = log(ta.values)[2:end] .- log(lag(ta).values)
#    logreturn = T[ta.values[t] for t in 1:length(ta)] |> log |> diff

    if method == "simple" 
      TimeArray(ta.timestamp[2:end], expm1(logreturn), ta.colnames) 
    elseif method == "log" 
      TimeArray(ta.timestamp[2:end], logreturn, ta.colnames) 
    else msg("only simple and log methods supported")
    end
end


aapl = TimeArray(AAPL.timestamp, AAPL.values, AAPL.colnames, FinancialSeries.Stock(FinancialSeries.Ticker("AAPL")))

# log-returns
println("Log returns timing")
for i = 1:10
    @time ret = percentchange(aapl["Adj. Close"], method="log")
end

# reactive signal updates
tsroll = Input(aapl[1:50])
#tsig = lift(ts -> values(sma(ts["Close"], 5))[end] > values(sma(ts["Close"], 40))[end], Bool, tsroll)
tsig = lift(ts -> (sma(ts["Close"], 5) .> sma(ts["Close"], 40)).values[end], Bool, tsroll)

nsteps = 1_000
vsig = Array(Bool, nsteps);
function vsigupd!(vsig::Vector{Bool}, nsteps::Integer)
    for i in 1:nsteps
        push!(tsroll, aapl[i:i+50])
        vsig[i] = tsig.value
    end
end

println(" ")
println("reactive signal timing")
expr_run = parse("@time vsigupd!(vsig, nsteps)")
for i = 1:10
    eval(expr_run)
end

