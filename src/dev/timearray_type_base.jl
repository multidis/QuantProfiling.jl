## perofrmance comparison for different TimeArray type definitions
using TimeSeries
using MarketData, MarketTechnicals
using Reactive

# log-returns
println("Log returns timing")
for i = 1:10
    @time ret = percentchange(AAPL["Adj. Close"], method="log")
end

# reactive signal updates
tsroll = Input(AAPL[1:50])
#tsig = lift(ts -> values(sma(ts["Close"], 5))[end] > values(sma(ts["Close"], 40))[end], Bool, tsroll)
tsig = lift(ts -> values(sma(ts["Close"], 5) .> sma(ts["Close"], 40))[end], Bool, tsroll)

nsteps = 1_000
vsig = Array(Bool, nsteps);
function vsigupd!(vsig::Vector{Bool}, nsteps::Integer)
    for i in 1:nsteps
        push!(tsroll, AAPL[i:i+50])
        vsig[i] = tsig.value
    end
end

println(" ")
println("reactive signal timing")
expr_run = parse("@time vsigupd!(vsig, nsteps)")
for i = 1:10
    eval(expr_run)
end

