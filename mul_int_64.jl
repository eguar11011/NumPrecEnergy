function mul_int64(loop::Int)
    data = Int64[
        158, 21, 7813, 632, 87, 14, 751, 201, 79, 26,
        158_862, 78_213, 425_763, 412_489, 852_362,
        23_546, 145_823, 352_689, 558_721
    ]

    println("Multiplication Computation (Int64 - unified set)")
    println("===============================================")

    acc = Int64(0)

    for k in 1:loop
        for a in data, b in data
            acc += a * b
        end
    end

    println("Resultado acumulado (acc) = $acc")
end

# Ejecutar cálculo
mul_int64(1_000_000)
