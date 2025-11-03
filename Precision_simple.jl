function generar_primos(n, T::Type{<:Integer})
    prime_List = T[2, 3, 5, 7, 11, 13]
    num_Actual = prime_List[end]
    
    while length(prime_List) != n
        num_Actual += one(T)  # suma 1 con el mismo tipo
        for j in prime_List
            if num_Actual % j == 0
                break
            end
            if j*j > num_Actual   # condición en enteros
                push!(prime_List, num_Actual)
                break
            end
        end
    end
    return prime_List
end

# Para enteros de 32 bits
primos32 = generar_primos(1_000_000, Int32)  # ⚠️ con Int32 no puedes ir más allá de ~2e9
println("Último primo: ", primos32[end])
