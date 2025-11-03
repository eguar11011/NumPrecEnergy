using LinearAlgebra
using DelimitedFiles

# Construcción de la matriz de Frank (n x n)
function frank(n::Int, T=Float64)
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
A = frank(n, Float64)
x_true = ones(Float64, n)
b = A * x_true

# Resolver con LU
F = lu(A)
x = F \ b

# Errores
forward_error = norm(x - x_true) / norm(x_true)
backward_error = norm(A * x - b) / (norm(A) * norm(x) + norm(b))
#condA = cond(A)
condA = 0
# Guardar resultados en CSV
header = ["n" "forward_error" "backward_error" "cond"]
data   = [n forward_error backward_error condA]

writedlm("result64.csv", vcat(header, data), ',')

println("Resultados (Float64):")
println("Forward error  = $forward_error")
println("Backward error = $backward_error")
#println("cond(A)        = $condA")
