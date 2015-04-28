## Reactive signal update performance: o, h, l, c vectors from TimeArray values-component
using TimeSeries
using Reactive

nma = 50
ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA.csv")

s_ohlc = Reactive.Input(ohlc_BA.values[1,:])
s_close = lift(s -> s[4], Float64, s_ohlc)
s_open = lift(s -> s[1], Float64, s_ohlc)

vsig = [s_close.value - s_open.value]
function vsigupd!(vsig::Vector{Float64}, nma::Int64, nmax::Int64)
    for i in 2:nmax
        push!(s_ohlc, ohlc_BA.values[i,:])
        push!(vsig, s_close.value - s_open.value)
    end
end

println("OHLC updates with 2 lift-signals:")
println("reactive signal updates timing")
expr_run = parse("@time vsigupd!(vsig, nma, length(ohlc_BA))")
for i = 1:5
    eval(expr_run)
end

### results
# elapsed time: 0.21731065 seconds (23552912 bytes allocated, 17.07% gc time)
### more lift-signals really add time

Profile.clear()  # in case we have any previous profiling data
@profile vsigupd!(vsig, nma, length(ohlc_BA))
Profile.print()

