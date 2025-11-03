#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="resultados_energia.csv"
ITER=1000
ENERGY_PATH="/sys/class/powercap/intel-rapl:0/energy_uj"

# === Lista de scripts Julia a medir ===
SCRIPTS=(
  # División
  "div_flot_32.jl"
  "div_flot_64.jl"
  "div_int_32.jl"
  "div_int_64.jl"

  # Multiplicación
  "mul_flot_32.jl"
  "mul_flot_64.jl"
  "mul_int_32.jl"
  "mul_int_64.jl"

  # Suma
  "sum_flot_32.jl"
  "sum_flot_64.jl"
  "sum_int_32.jl"
  "sum_int_64.jl"
)

# === Verificación de acceso al contador de energía ===
if [ ! -r "$ENERGY_PATH" ]; then
  echo "❌ ERROR: No se puede leer $ENERGY_PATH. Ejecute con sudo o cambie permisos."
  exit 1
fi

# === Crear archivo CSV si no existe ===
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "timestamp,script,iteracion,tiempo_s(segundos),energia_j(julios)" > "$OUTPUT_FILE"
fi

# === Ejecución de cada script Julia ===
for script in "${SCRIPTS[@]}"; do
  if [ ! -f "$script" ]; then
    echo "⚠️ Archivo $script no encontrado, se omite."
    continue
  fi

  echo "=== Procesando: $script ==="

  for i in $(seq 1 $ITER); do
    START=$(cat "$ENERGY_PATH")
    TIME_START=$(date +%s.%N)

    julia "$script" > /dev/null 2>&1

    TIME_END=$(date +%s.%N)
    END=$(cat "$ENERGY_PATH")

    # Manejo de overflow del contador RAPL
    DELTA_UJ=$((END - START))
    if [ "$DELTA_UJ" -lt 0 ]; then
      DELTA_UJ=$(( END + (1<<32) - START ))
    fi

    # Conversión a julios y segundos
    ENERGY_J=$(awk -v d="$DELTA_UJ" 'BEGIN{printf "%.6f", d/1000000}')
    DURATION=$(awk -v a="$TIME_START" -v b="$TIME_END" 'BEGIN{printf "%.6f", b - a}')
    TIMESTAMP=$(date -Iseconds)

    # Guardar resultados
    echo "$TIMESTAMP,$script,$i,$DURATION,$ENERGY_J" >> "$OUTPUT_FILE"

    printf "\r%s  iter %3d  t=%8s s  e=%8s J" "$script" "$i" "$DURATION" "$ENERGY_J"
  done

  echo -e "\n✅ Hecho con $script"
done

echo "✅ Resultados guardados en $OUTPUT_FILE"
