#!/bin/bash
# Usage: ./scripts/run-test.sh <strategy> <scenario> <run_number>

STRATEGY=$1
SCENARIO=$2
RUN=$3
NAMESPACE="academic"
RESULTS_DIR="results/${STRATEGY}/${SCENARIO}"
BASE_URL="http://localhost:30080"

if [ -z "$STRATEGY" ] || [ -z "$SCENARIO" ] || [ -z "$RUN" ]; then
    echo "Usage: $0 <strategy> <scenario> <run_number>"
    echo "  Strategies: s1 s2 s3 s4 s5 s6 s7"
    echo "  Scenarios:  c1 c2 c3 c4"
    echo "  Run:        1 2 3 4 5"
    exit 1
fi

mkdir -p "$RESULTS_DIR"

echo ""
echo "# Stratégie: $STRATEGY | Scénario: $SCENARIO | Run: $RUN"
echo ""

# 1. Reset
echo "[1/5] Reset du déploiement..."
./scripts/reset-deployment.sh

# 2. Appliquer la stratégie d'autoscaling
echo "[2/5] Application de la stratégie $STRATEGY..."
case $STRATEGY in
    s1) kubectl apply -f k8s/autoscaling/s1-hpa-cpu.yaml ;;
    s2) kubectl apply -f k8s/autoscaling/s2-hpa-custom.yaml ;;
    s3) kubectl apply -f k8s/autoscaling/s3-vpa-off.yaml ;;
    s4) kubectl apply -f k8s/autoscaling/s4-vpa-auto.yaml ;;
    s5) kubectl apply -f k8s/autoscaling/s5-hpa-rps.yaml
        kubectl apply -f k8s/autoscaling/s5-vpa-mem.yaml ;;
    s6) kubectl apply -f k8s/autoscaling/s6-hpa-ca.yaml ;;
    s7) kubectl apply -f k8s/autoscaling/s7-keda.yaml ;;
    *)  echo "Stratégie inconnue: $STRATEGY"; exit 1 ;;
esac

echo "Attente activation autoscaler (15s)..."
sleep 15

# 2b. Vérification du NodePort
echo "Vérification connectivité NodePort..."
if ! curl -sf --max-time 5 "${BASE_URL}/health" > /dev/null; then
    echo "ERREUR: NodePort non accessible sur ${BASE_URL}"
    echo "Vérifiez: kubectl get svc fastapi-nodeport -n $NAMESPACE"
    exit 1
fi
echo "NodePort OK"

# 3. Lancer le test k6
echo "[3/5] Lancement du test k6 ($SCENARIO)..."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
K6_OUTPUT="$RESULTS_DIR/run${RUN}_${TIMESTAMP}.json"

case $SCENARIO in
    c1) K6_SCRIPT="c1-normal.js" ;;
    c2) K6_SCRIPT="c2-inscriptions.js" ;;
    c3) K6_SCRIPT="c3-resultats.js" ;;
    c4) K6_SCRIPT="c4-compute.js" ;;
    *)  echo "Scénario inconnu: $SCENARIO"; exit 1 ;;
esac

k6 run \
    --out json="$K6_OUTPUT" \
    --env BASE_URL="$BASE_URL" \
    --tag strategy="$STRATEGY" \
    --tag scenario="$SCENARIO" \
    --tag run="$RUN" \
    "k6/${K6_SCRIPT}" \
    2>&1 | tee "$RESULTS_DIR/run${RUN}_${TIMESTAMP}.log"

# 4. Collecter les métriques Kubernetes
echo "[4/5] Collecte des métriques Kubernetes..."
METRICS_FILE="$RESULTS_DIR/run${RUN}_${TIMESTAMP}_metrics.json"

{
    echo "{"
    echo "  \"strategy\": \"$STRATEGY\","
    echo "  \"scenario\": \"$SCENARIO\","
    echo "  \"run\": $RUN,"
    echo "  \"timestamp\": \"$TIMESTAMP\","

    echo "  \"hpa\":"
    kubectl get hpa -n $NAMESPACE -o json 2>/dev/null || echo "{}"
    echo ","

    echo "  \"vpa\":"
    kubectl get vpa -n $NAMESPACE -o json 2>/dev/null || echo "{}"
    echo ","

    echo "  \"pods\":"
    kubectl get pods -n $NAMESPACE -l app=fastapi-backend -o json
    echo ","

    echo "  \"top_pods\": \"$(kubectl top pods -n $NAMESPACE -l app=fastapi-backend 2>/dev/null)\""

    echo "}"
} > "$METRICS_FILE"

# 5. Nettoyage
echo "[5/5] Nettoyage..."
./scripts/reset-deployment.sh

echo ""
echo "=== Test $STRATEGY/$SCENARIO/run$RUN terminé ==="
echo "Résultats: $K6_OUTPUT"
echo "Métriques: $METRICS_FILE"
echo "Logs:      $RESULTS_DIR/run${RUN}_${TIMESTAMP}.log"