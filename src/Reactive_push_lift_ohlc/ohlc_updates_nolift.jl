## Reactive signal update performance: o, h, l, c vectors from TimeArray values-component
using TimeSeries
using Reactive

nma = 50
ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA.csv")

s_ohlc = Reactive.Input(ohlc_BA.values[1,:])
#s_close = lift(s -> s[4], s_ohlc, typ=Float64)

vsig = [s_close.value]
function vsigupd!(vsig::Vector{Float64}, nma::Int64, nmax::Int64)
    for i in 2:nmax
        push!(s_ohlc, ohlc_BA.values[i,:])
        #push!(vsig, s_close.value)
        push!(vsig, 15.0)
    end
end

println("OHLC updates o, h, l, c vector from TimeArray values-component:")
println("reactive signal updates timing")
expr_run = parse("@time vsigupd!(vsig, nma, length(ohlc_BA))")
for i = 1:5
    eval(expr_run)
end

### results
# elapsed time: 0.056466796 seconds (12505448 bytes allocated, 72.50% gc time)

Profile.clear()  # in case we have any previous profiling data
@profile vsigupd!(vsig, nma, length(ohlc_BA))
Profile.print()

