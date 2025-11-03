function generar_primos_flotantes(n, T::Type{<:AbstractFloat})
    prime_List = T[2, 3, 5, 7, 11, 13]
    num_Actual = prime_List[end]

    while length(prime_List) != n
        num_Actual += one(T)
        raiz_Actual = sqrt(num_Actual)

        for j in prime_List
            if j > raiz_Actual
                push!(prime_List, num_Actual)
                break
            end

            q = num_Actual / j
            # chequeo "casi entero"
            if abs(q - round(q)) < eps(T)
                break
            end
        end
    end
    return prime_List
end

# Ejemplo pequeño (para prueba)
primos32 = generar_primos_flotantes(1_000_000, Float32)
println("Último primo:", primos32[end])
