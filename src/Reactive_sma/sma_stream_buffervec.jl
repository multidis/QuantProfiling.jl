## SMA performance: buffer vector version
using TimeSeries, MarketTechnicals
using Reactive

nma = 50
ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA.csv")
sma_ta = sma(ohlc_BA["Close"], nma)

s_ohlc = Reactive.Input(ohlc_BA.values[nma,:])

function smabuffer!(buffer, val_ohlc)
    push!(buffer, val_ohlc[4]) # add new close price
    shift!(buffer) # remove the earliest element
    return buffer
end
s_sma = lift(mean, foldl(smabuffer!, ohlc_BA["Close"].values[1:nma], s_ohlc))

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

println("SMA foldl-buffer version:")
println("reactive signal updates timing")
expr_run = parse("@time vsigupd!(vsig, nma, length(ohlc_BA))")
for i = 1:5
    eval(expr_run)
end

### results
# elapsed time: 0.214774855 seconds (21274016 bytes allocated, 19.48% gc time)

Profile.clear()  # in case we have any previous profiling data
@profile vsigupd!(vsig, nma, length(ohlc_BA))
Profile.print()

