## Reactive signal update performance: TimeArray slices
using TimeSeries
using Reactive

nma = 50
ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA.csv")

s_ohlc = Reactive.Input(ohlc_BA[1:nma])
s_close = lift(s -> values(s["Close"])[end], s_ohlc, typ=Float64)

vsig = [s_close.value]
function vsigupd!(vsig::Vector{Float64}, nma::Int64, nmax::Int64)
    for i in (nma + 1):nmax
        push!(s_ohlc, ohlc_BA[i-nma:i])
        push!(vsig, s_close.value)
    end
end

println("OHLC updates TimeArray slices version:")
println("reactive signal updates timing")
expr_run = parse("@time vsigupd!(vsig, nma, length(ohlc_BA))")
for i = 1:5
    eval(expr_run)
end

### results
# elapsed time: 1.062034687 seconds (367636432 bytes allocated, 33.78% gc time)

Profile.clear()  # in case we have any previous profiling data
@profile vsigupd!(vsig, nma, length(ohlc_BA))
Profile.print()

