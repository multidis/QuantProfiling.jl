## Reactive signal update performance: o, h, l, c vectors from TimeArray values-component
using TimeSeries
using Reactive

nma = 50
ohlc_BA = TimeSeries.readtimearray("../../data/OHLC_BA.csv")

s_ohlc = Reactive.Input((ohlc_BA.timestamp[1], vec(ohlc_BA.values[1,:])))
s_close = lift(s -> s[2][4], s_ohlc, typ=Float64)

vsig = [s_close.value]
function vsigupd!(vsig::Vector{Float64}, nma::Int64, nmax::Int64)
    for i in 2:nmax
        push!(s_ohlc, (ohlc_BA.timestamp[i], vec(ohlc_BA.values[i,:])))  ## most time here
        ##tarow = ohlc_BA[i]
        ##push!(s_ohlc, (tarow.timestamp[1], tarow.values))  ## NOT doing this - much longer
        push!(vsig, s_close.value)
    end
end

println("OHLC updates o, h, l, c vector from TimeArray values-component in tuple with its timestamp:")
println("reactive signal updates timing")
expr_run = parse("@time vsigupd!(vsig, nma, length(ohlc_BA))")
for i = 1:5
    eval(expr_run)
end

### results
# elapsed time: longer than ohlc_updates_vector_tavalues.jl but less than a factor of two

Profile.clear()  # in case we have any previous profiling data
@profile vsigupd!(vsig, nma, length(ohlc_BA))
Profile.print()

