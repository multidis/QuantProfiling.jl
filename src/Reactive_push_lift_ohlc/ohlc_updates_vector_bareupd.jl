## Reactive signal update performance: o, h, l, c vectors, bare updates
using TimeSeries
using Reactive

nma = 50
ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA.csv")

s_ohlc = Reactive.Input(ohlc_BA.values[1,:])
s_close = lift(s -> s[4], Float64, s_ohlc)

#vsig = [s_close.value]
function vsigupd!(vsig::Vector{Float64}, nma::Int64, nmax::Int64)
    for i in 2:nmax
        push!(s_ohlc, ohlc_BA.values[i,:])
        #push!(vsig, s_close.value)
    end
end

println("OHLC updates o, h, l, c vector from TimeArray values-component:")
println("reactive signal updates timing")
expr_run = parse("@time vsigupd!(vsig, nma, length(ohlc_BA))")
for i = 1:5
    eval(expr_run)
end

### results
# elapsed time: 0.129969223 seconds (16745888 bytes allocated, 29.56% gc time)
### growing vsig-vector is not limiting performance (good news for blotter implementation)

Profile.clear()  # in case we have any previous profiling data
@profile vsigupd!(vsig, nma, length(ohlc_BA))
Profile.print()

