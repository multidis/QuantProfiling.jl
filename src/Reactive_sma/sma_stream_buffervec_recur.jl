## SMA performance: buffer vector version with recursive mean instead of direct summation
using TimeSeries, MarketTechnicals
using Reactive

nma = 50
ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA.csv")
sma_ta = sma(ohlc_BA["Close"], nma)

s_ohlc = Reactive.Input(ohlc_BA.values[nma,:])

function smarecbuffer!(prev, val_ohlc)
    buffer, prev_sma = prev
    
    # update SMA value recursively
    new_sma = prev_sma + (val_ohlc[4] - buffer[1])/float(nma)
    
    # update buffer
    push!(buffer, val_ohlc[4]) # add new close price
    shift!(buffer) # remove the earliest element
    
    # new_sma becomes prev_sma in the next call
    return (buffer, new_sma)
end
s_sma = lift(s -> s[2], foldl(smarecbuffer!, (ohlc_BA["Close"].values[1:nma], mean(ohlc_BA["Close"].values[1:nma])), s_ohlc))

vsig = [s_sma.value]
function vsigupd!(vsig::Vector{Float64}, nma::Int64, nmax::Int64)
    for i in (nma + 1):nmax
        push!(s_ohlc, ohlc_BA.values[i,:])
        push!(vsig, s_sma.value)
    end
end

# verify sma values
vsigupd!(vsig, nma, length(ohlc_BA))
println("check if SMA values are correct:")
println(mean(abs(vsig - sma_ta.values)) < 1e-7)
println("")

println("SMA foldl-buffer version with recursive calculation:")
println("reactive signal updates timing")
expr_run = parse("@time vsigupd!(vsig, nma, length(ohlc_BA))")
for i = 1:5
    eval(expr_run)
end

### results
# elapsed time: 0.266140198 seconds (23986336 bytes allocated, 16.14% gc time)
### longer and more complex than mean(buffer): no point for this recursive version

Profile.clear()  # in case we have any previous profiling data
@profile vsigupd!(vsig, nma, length(ohlc_BA))
Profile.print()

