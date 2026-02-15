#!/bin/bash
# Lance les 24 tests : 4 stratégies × 2 scénarios × 3 répétitions

STRATEGIES=("s1" "s2" "s4" "s7")
SCENARIOS=("c2" "c4")
RUNS=3

TOTAL=$((${#STRATEGIES[@]} * ${#SCENARIOS[@]} * RUNS))
COUNT=0

echo "=============================================="
echo " Lancement de $TOTAL tests"
echo " Durée estimée: ~33 minutes"
echo " Début: $(date)"
echo "=============================================="

for strategy in "${STRATEGIES[@]}"; do
    for scenario in "${SCENARIOS[@]}"; do
        for run in $(seq 1 $RUNS); do
            COUNT=$((COUNT + 1))
            echo ""
            echo ">>>>>>>>>> Test $COUNT/$TOTAL : $strategy/$scenario/run$run <<<<<<<<<<"
            ./scripts/run-test.sh "$strategy" "$scenario" "$run"
            echo "Pause de 15s avant le prochain test..."
            sleep 15
        done
    done
done

echo ""
echo "=============================================="
echo " $TOTAL tests terminés !"
echo " Fin: $(date)"
echo "=============================================="