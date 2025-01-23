
function MP_heatmap1( xTicks::Vector{<:Real}, yTicks::Vector{<:Real}, data::Vector{<:Real}, stepSize = 100; kwargs... )
	dataMatrix = zeros( 
						length(unique(yTicks)), 
						length(unique(xTicks))
					  )

	x 	= unique(xTicks)
	y 	= unique(yTicks)

	for d in 1:length(data)
		if ( length(data) != length(xTicks) || length(data) != length(yTicks))
			error("Arrays must be the same size!")
		end

		r = convert(Int, yTicks[d]/stepSize + 1) # gives row index 
		c = convert(Int, xTicks[d]/stepSize + 1) # gives row index 

		dataMatrix[r,c] = data[d]
	end


    hm = Plots.heatmap(x,y,dataMatrix; kwargs...)

	return hm
end

hm = MP_heatmap1(df.EMins, df.EMaxs, df.NPassedSignal, c=:thermal)