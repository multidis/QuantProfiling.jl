## Reactive signal update performance: o, h, l, c tuple from TimeArray values-component
using TimeSeries
using Reactive

nma = 50
ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA.csv")

ohlc_tup = (ohlc_BA.values[1,1], ohlc_BA.values[1,2], ohlc_BA.values[1,3], ohlc_BA.values[1,4])
s_ohlc = Reactive.Input(ohlc_tup)
s_close = lift(s -> s[4], Float64, s_ohlc)

vsig = [s_close.value]
function vsigupd!(vsig::Vector{Float64}, nma::Int64, nmax::Int64)
    for i in 2:nmax
        ohlc_tup = (ohlc_BA.values[i,1], ohlc_BA.values[i,2], ohlc_BA.values[i,3], ohlc_BA.values[i,4])
        push!(s_ohlc, ohlc_tup)
        push!(vsig, s_close.value)
    end
end

println("OHLC updates o, h, l, c tuple:")
println("reactive signal updates timing")
expr_run = parse("@time vsigupd!(vsig, nma, length(ohlc_BA))")
for i = 1:5
    eval(expr_run)
end

### results
# elapsed time: 0.171515629 seconds (20491784 bytes allocated, 21.96% gc time)
### tuple is less efficient than vector, and requires more data restructuring anyway

Profile.clear()  # in case we have any previous profiling data
@profile vsigupd!(vsig, nma, length(ohlc_BA))
Profile.print()

