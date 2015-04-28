## Reactive signal update performance: o, h, l, c vectors from TimeArray values-component
using TimeSeries
using Reactive

nma = 50
ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA.csv")

s_ohlc = Reactive.Input(ohlc_BA.values[1,:])
#s_close = lift(s -> s[4], Float64, s_ohlc)
#s_open = lift(s -> s[1], Float64, s_ohlc)

vsig = [s_ohlc.value[4] - s_ohlc.value[1]]
function vsigupd!(vsig::Vector{Float64}, nma::Int64, nmax::Int64)
    for i in 2:nmax
        push!(s_ohlc, ohlc_BA.values[i,:])
        #ohlc_now = s_ohlc.value
        #push!(vsig, ohlc_now[4] - ohlc_now[1])
        push!(vsig, s_ohlc.value[4] - s_ohlc.value[1]) ## this is fine, calling s.value is efficient
    end
end

println("OHLC updates with signal value components instead of 2 lift-signals:")
println("reactive signal updates timing")
expr_run = parse("@time vsigupd!(vsig, nma, length(ohlc_BA))")
for i = 1:5
    eval(expr_run)
end

### results
# elapsed time: 0.062989983 seconds (13133720 bytes allocated, 62.13% gc time)
### use as few lift-signals as possible!

Profile.clear()  # in case we have any previous profiling data
@profile vsigupd!(vsig, nma, length(ohlc_BA))
Profile.print()

