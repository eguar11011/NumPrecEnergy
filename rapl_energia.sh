#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="resultados_energia.csv"
ITER=500
ENERGY_PATH="/sys/class/powercap/intel-rapl:0/energy_uj"

# Lista de scripts exacta
SCRIPTS=(
  "Precision_doble.jl"
  "Flotantes_precision_simple.jl"
  "Precision_simple.jl"
  "Flotantes_precision_doble.jl"
)

# Verificar acceso a medición de energía
if [ ! -r "$ENERGY_PATH" ]; then
  echo "ERROR: No se puede leer $ENERGY_PATH. Ejecute con sudo o cambie permisos."
  exit 1
fi

# Crear CSV con encabezado si no existe
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "timestamp,script,iteracion,tiempo_s(segundos),energia_j(julios)" > "$OUTPUT_FILE"
fi

for script in "${SCRIPTS[@]}"; do
  echo "=== Procesando: $script ==="
  ext="${script##*.}"

  # Preparar comando según tipo
  case "$ext" in
    cpp)
      if [ ! -f "$script" ]; then
        echo "Archivo $script no encontrado, se omite."
        continue
      fi
      bin="./bin_$(basename "$script" .cpp)"
      if [ ! -x "$bin" ] || [ "$script" -nt "$bin" ]; then
        echo "Compilando $script..."
        g++ -O2 -std=c++17 -march=native -pipe -o "$bin" "$script"
      fi
      run_cmd=( "$bin" )
      ;;
    py)
      run_cmd=( python3 "$script" )
      ;;
    jl)
      run_cmd=( julia "$script" )
      ;;
    *)
      echo "Extensión $ext no soportada, se omite."
      continue
      ;;
  esac

  for i in $(seq 1 $ITER); do
    START=$(cat "$ENERGY_PATH")
    TIME_START=$(date +%s.%N)

    "${run_cmd[@]}" > /dev/null 2>&1

    TIME_END=$(date +%s.%N)
    END=$(cat "$ENERGY_PATH")

    DELTA_UJ=$((END - START))
    if [ "$DELTA_UJ" -lt 0 ]; then
      DELTA_UJ=$(( END + (1<<32) - START ))
    fi

    ENERGY_J=$(awk -v d="$DELTA_UJ" 'BEGIN{printf "%.6f", d/1000000}')
    DURATION=$(awk -v a="$TIME_START" -v b="$TIME_END" 'BEGIN{printf "%.6f", b - a}')
    TIMESTAMP=$(date -Iseconds)

    echo "$TIMESTAMP,$script,$i,$DURATION,$ENERGY_J" >> "$OUTPUT_FILE"

    printf "\r%s  iter %3d  t=%8s s  e=%8s J" "$script" "$i" "$DURATION" "$ENERGY_J"
  done
  echo -e "\nHecho con $script"
done

echo "✅ Resultados guardados en $OUTPUT_FILE"
