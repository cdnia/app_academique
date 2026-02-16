#!/bin/bash
NAMESPACE="academic"

echo "=== Nettoyage des autoscalers ==="
kubectl delete hpa --all -n $NAMESPACE --ignore-not-found 2>/dev/null
kubectl delete vpa --all -n $NAMESPACE --ignore-not-found 2>/dev/null
kubectl delete scaledobject --all -n $NAMESPACE --ignore-not-found 2>/dev/null

echo "=== Reset replicas ==="
kubectl scale deployment fastapi-backend --replicas=2 -n $NAMESPACE

echo "=== Nettoyage table students (hors données initiales) ==="
kubectl exec -n $NAMESPACE postgresql-0 -- \
  psql -U postgres -d academic_db -c "DELETE FROM grades WHERE student_id > 3; DELETE FROM students WHERE id > 3;"

echo "=== Attente stabilisation (15s) ==="
sleep 15
kubectl get pods -n $NAMESPACE -l app=fastapi-backend
echo "=== Reset terminé ==="