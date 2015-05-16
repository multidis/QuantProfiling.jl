## Reactive signal update performance: o, h, l, c vectors from TimeArray values-component
using TimeSeries
using Reactive

nma = 50
ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA.csv")

#s_ohlc = Reactive.Input(ohlc_BA.values[1,:])
s_ohlc = Reactive.Input(ohlc_BA[1])
s_close = lift(s -> s.values[4], s_ohlc, typ=Float64)

vsig = [s_close.value]
function vsigupd!(vsig::Vector{Float64}, nma::Int64, nmax::Int64)
    for i in 2:nmax
        #push!(s_ohlc, ohlc_BA.values[i,:])
        push!(s_ohlc, ohlc_BA[i])
        push!(vsig, s_close.value)
    end
end

println("OHLC updates o, h, l, c row from TimeArray (preserves timestamp of ohlc-row):")
println("reactive signal updates timing")
expr_run = parse("@time vsigupd!(vsig, nma, length(ohlc_BA))")
for i = 1:5
    eval(expr_run)
end

### results
# elapsed time: at least twice as long as ohlc_updates_vector_tavalues.jl

Profile.clear()  # in case we have any previous profiling data
@profile vsigupd!(vsig, nma, length(ohlc_BA))
Profile.print()

