import { useState } from 'react'

const API_URL = 'http://localhost:8000'

function Compute() {
  const [iterations, setIterations] = useState(1000000)
  const [result, setResult] = useState(null)
  const [loading, setLoading] = useState(false)
  const [duration, setDuration] = useState(null)

  const handleCompute = async () => {
    setLoading(true)
    setResult(null)
    setDuration(null)

    const start = performance.now()
    try {
      const res = await fetch(`${API_URL}/api/v1/compute/?iterations=${iterations}`)
      const data = await res.json()
      const end = performance.now()

      setResult(data.result)
      setDuration(((end - start) / 1000).toFixed(3))
    } catch (err) {
      console.error('Erreur calcul:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div>
      <h2>Calcul intensif (CPU-bound)</h2>
      <p>Ce endpoint simule un traitement lourd pour solliciter le HPA.</p>
      <div className="compute-form">
        <label>
          Nombre d'itérations :
          <input
            type="number"
            min="1"
            max="10000000"
            value={iterations}
            onChange={(e) => setIterations(Number(e.target.value))}
          />
        </label>
        <button onClick={handleCompute} disabled={loading}>
          {loading ? 'Calcul en cours...' : 'Lancer le calcul'}
        </button>
      </div>

      {result !== null && (
        <div className="result">
          <p>Résultat : <strong>{result}</strong></p>
          <p>Temps de réponse : <strong>{duration}s</strong></p>
        </div>
      )}
    </div>
  )
}

export default Compute