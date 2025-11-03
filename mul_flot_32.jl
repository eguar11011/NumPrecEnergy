function mul_float32(loop::Int)
    data = Float32[
        158.0f0, 21.0f0, 7813.0f0, 632.0f0, 87.0f0, 14.0f0, 751.0f0, 201.0f0, 79.0f0, 26.0f0,
        158_862.0f0, 78_213.0f0, 425_763.0f0, 412_489.0f0, 852_362.0f0,
        23_546.0f0, 145_823.0f0, 352_689.0f0, 558_721.0f0
    ]

    println("Multiplication Computation (Float32 - unified set)")
    println("================================================")

    acc = 0.0f0

    for k in 1:loop
        for a in data, b in data
            acc += a * b
        end
    end

    println("Resultado acumulado (acc) = $acc")
end

# Ejecutar cálculo
mul_float32(1_000_000)
