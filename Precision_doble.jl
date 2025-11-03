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

primos64 = generar_primos(1_000_000, Int64)  
println("Último primo: ", primos64[end])
