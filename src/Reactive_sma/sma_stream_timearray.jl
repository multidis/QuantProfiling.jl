## SMA performance: MarketTechnicals.jl TimeArray version
using TimeSeries, MarketTechnicals
using Reactive

nma = 50
ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA.csv")
sma_ta = sma(ohlc_BA["Close"], nma)

s_ohlc = Reactive.Input(ohlc_BA[1:nma])
s_close = lift(s -> values(s["Close"])[end], s_ohlc, typ=Float64)
s_sma = lift(s -> values(sma(s["Close"], nma))[end], s_ohlc, typ=Float64)

vsig = [s_sma.value]
function vsigupd!(vsig::Vector{Float64}, nma::Int64, nmax::Int64)
    for i in (nma + 1):nmax
        push!(s_ohlc, ohlc_BA[i-nma:i])
        push!(vsig, s_sma.value)
    end
end

println("SMA MarketTechnicals TimeArray version:")
println("reactive signal updates timing")
expr_run = parse("@time vsigupd!(vsig, nma, length(ohlc_BA))")
for i = 1:5
    eval(expr_run)
end

### results
# elapsed time: 1.771798644 seconds (577773184 bytes allocated, 29.26% gc time)
### way too long, partially due to inefficient TimeArray-slicing updates (see ../Reactive_push_lift_ohlc/)

Profile.clear()  # in case we have any previous profiling data
@profile vsigupd!(vsig, nma, length(ohlc_BA))
Profile.print()

