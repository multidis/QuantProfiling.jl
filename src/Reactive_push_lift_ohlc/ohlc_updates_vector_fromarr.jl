## Reactive signal update performance: o, h, l, c vectors from 2D array
using TimeSeries
using Reactive

nma = 50
ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA.csv")
ohlc_valarr = ohlc_BA.values

s_ohlc = Reactive.Input(ohlc_valarr[1,:])
s_close = lift(s -> s[4], s_ohlc, typ=Float64)

vsig = [s_close.value]
function vsigupd!(vsig::Vector{Float64}, nma::Int64, nmax::Int64)
    for i in 2:nmax
        push!(s_ohlc, ohlc_valarr[i,:])
        push!(vsig, s_close.value)
    end
end

println("OHLC updates o, h, l, c vector from 2D array rows:")
println("reactive signal updates timing")
expr_run = parse("@time vsigupd!(vsig, nma, length(ohlc_BA))")
for i = 1:5
    eval(expr_run)
end

### results
# elapsed time: 0.135502571 seconds (17479632 bytes allocated, 28.15% gc time)
### no advantage of pre-separating values-array from TimeArray (good news)

Profile.clear()  # in case we have any previous profiling data
@profile vsigupd!(vsig, nma, length(ohlc_BA))
Profile.print()

