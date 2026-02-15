import { useState } from 'react'

const API_URL = 'http://localhost:8000'

function Grades() {
  const [grades, setGrades] = useState([])
  const [studentId, setStudentId] = useState('')
  const [subject, setSubject] = useState('')
  const [loaded, setLoaded] = useState(false)

  const fetchGrades = async () => {
    try {
      const params = new URLSearchParams()
      if (studentId) params.append('student_id', studentId)
      if (subject) params.append('subject', subject)

      const res = await fetch(`${API_URL}/api/v1/grades/?${params}`)
      const data = await res.json()
      setGrades(data)
      setLoaded(true)
    } catch (err) {
      console.error('Erreur chargement notes:', err)
    }
  }

  return (
    <div>
      <h2>Consultation des notes</h2>
      <div className="filters">
        <input
          type="number"
          placeholder="ID étudiant"
          value={studentId}
          onChange={(e) => setStudentId(e.target.value)}
        />
        <input
          type="text"
          placeholder="Matière"
          value={subject}
          onChange={(e) => setSubject(e.target.value)}
        />
        <button onClick={fetchGrades}>Rechercher</button>
      </div>

      {loaded && (
        <>
          <p>{grades.length} résultat(s) trouvé(s)</p>
          <table>
            <thead>
              <tr>
                <th>ID Étudiant</th>
                <th>Matière</th>
                <th>Note</th>
                <th>Semestre</th>
              </tr>
            </thead>
            <tbody>
              {grades.map((g) => (
                <tr key={g.id}>
                  <td>{g.student_id}</td>
                  <td>{g.subject}</td>
                  <td>{g.score}</td>
                  <td>{g.semester}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </>
      )}
    </div>
  )
}

export default Grades