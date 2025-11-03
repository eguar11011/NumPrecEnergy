using LinearAlgebra
using DelimitedFiles

# Matriz de Frank
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
A32 = frank(n, Float32)
x_true64 = ones(Float64, n)   # solución exacta
b32 = A32 * ones(Float32, n)

# LU en simple
F32 = lu(A32)
x32 = F32 \ b32   # solución inicial en Float32
x_refined = Vector{Float64}(x32)  # arranque en Float64

# Convertir a Float64 para cálculos de residuo
A64 = Matrix{Float64}(A32)
b64 = Vector{Float64}(b32)

function refinamiento_frank(n::Int; tol=1e-14, maxiter=20)
    # Construcción matriz y datos
    A32 = frank(n, Float32)
    x_true64 = ones(Float64, n)
    b32 = A32 * ones(Float32, n)

    # Factorización LU en simple
    F32 = lu(A32)
    x32 = F32 \ b32
    x_refined = Vector{Float64}(x32)

    # Conversión a doble para cálculos exactos
    A64 = Matrix{Float64}(A32)
    b64 = Vector{Float64}(b32)

    for k in 1:maxiter
        r64 = b64 - A64 * x_refined
        d32 = F32 \ Vector{Float32}(r64)
        x_refined += Vector{Float64}(d32)

        forward_error = norm(x_refined - x_true64) / norm(x_true64)
        if forward_error < tol
            println("Convergió en iteración $k con forward error = $forward_error")
            
            break
        end
    end

    # Métricas finales
    forward_error = norm(x_refined - x_true64) / norm(x_true64)
    backward_error = norm(A64 * x_refined - b64) / (norm(A64)*norm(x_refined) + norm(b64))
    condA = 0

    return (forward_error, backward_error, condA)
end


forward_error, backward_error, condA = refinamiento_frank(n)

header = ["n" "forward_error" "backward_error" "cond"]
data   = [n forward_error backward_error condA]
writedlm("refinamiento32.csv", vcat(header, data), ',')


println("Resultados (Float32 - Refinado en Float64):")
println("Forward error  = $forward_error")
println("Backward error = $backward_error")
#println("cond(A)        = $condA")
