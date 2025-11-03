function mul_float64(loop::Int)
    data = Float64[
        158.0, 21.0, 7813.0, 632.0, 87.0, 14.0, 751.0, 201.0, 79.0, 26.0,
        158_862.0, 78_213.0, 425_763.0, 412_489.0, 852_362.0,
        23_546.0, 145_823.0, 352_689.0, 558_721.0
    ]

    println("Multiplication Computation (Float64 - unified set)")
    println("================================================")

    acc = 0.0

    for k in 1:loop
        for a in data, b in data
            acc += a * b
        end
    end

    println("Resultado acumulado (acc) = $acc")
end

# Ejecutar cálculo
mul_float64(1_000_000)
