#!/bin/bash
# Lance les 24 tests : 4 stratégies × 2 scénarios × 3 répétitions
STRATEGIES=("s1" "s2" "s4" "s7")
SCENARIOS=("c2" "c4")
RUNS=3
TOTAL=$((${#STRATEGIES[@]} * ${#SCENARIOS[@]} * RUNS))
COUNT=0
ESTIMATED_MINUTES=33
START_EPOCH=$(date +%s)

echo "=============================================="
echo " Lancement de $TOTAL tests"
echo " Durée estimée: ~${ESTIMATED_MINUTES} minutes"
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

END_EPOCH=$(date +%s)
ELAPSED_SECONDS=$((END_EPOCH - START_EPOCH))
ELAPSED_MINUTES=$((ELAPSED_SECONDS / 60))
ELAPSED_REMAINING=$((ELAPSED_SECONDS % 60))
ESTIMATED_SECONDS=$((ESTIMATED_MINUTES * 60))
DIFF_SECONDS=$((ELAPSED_SECONDS - ESTIMATED_SECONDS))

if [ $DIFF_SECONDS -ge 0 ]; then
    DIFF_SIGN="+"
else
    DIFF_SIGN="-"
    DIFF_SECONDS=$((-DIFF_SECONDS))
fi
DIFF_MINUTES=$((DIFF_SECONDS / 60))
DIFF_REMAINING=$((DIFF_SECONDS % 60))

echo ""
echo "=============================================="
echo " $TOTAL tests terminés !"
echo " Début: $(date -d @$START_EPOCH 2>/dev/null || date -r $START_EPOCH)"
echo " Fin:   $(date)"
echo " Durée réelle:  ${ELAPSED_MINUTES}m ${ELAPSED_REMAINING}s"
echo " Durée estimée: ${ESTIMATED_MINUTES}m 00s"
echo " Différence:    ${DIFF_SIGN}${DIFF_MINUTES}m ${DIFF_REMAINING}s"
echo "=============================================="