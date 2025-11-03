using LinearAlgebra
using DelimitedFiles

# Construcción de la matriz de Frank (n x n)
function frank(n::Int, T=Float32)
    A = zeros(T, n, n)
    for i in 1:n
        for j in 1:n
            if j == i
                A[i,j] = T(n - i + 1)
            elseif j == i + 1 || j == i - 1
                A[i,j] = T(n - max(i,j) + 1)
            end
        end
    end
    return A
end

# Parámetros
n = 1_000_0 
A = frank(n, Float32)
x_true = ones(Float32, n)
b = A * x_true

A_gpu = CuArray(A)
b_gpu = CuArray(b)
# Resolver con LU
F = lu(A_gpu)
x = F \ b_gpu

# Errores
forward_error = norm(x - x_true) / norm(x_true)
backward_error = norm(A * x - b) / (norm(A) * norm(x) + norm(b))
# condA = cond(Matrix{Float64}(A))  # calcular cond con más precisión
condA = 0
# Guardar resultados en CSV
header = ["n" "forward_error" "backward_error" "cond"]
data   = [n forward_error backward_error condA]

writedlm("result32.csv", vcat(header, data), ',')


println("Resultados (Float32):")
println("Forward error  = $forward_error")
println("Backward error = $backward_error")
#println("cond(A)        = $condA")
