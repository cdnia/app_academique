import { useState, useEffect } from 'react'

const API_URL = 'http://localhost:8000'

function Students() {
  const [students, setStudents] = useState([])
  const [total, setTotal] = useState(0)
  const [page, setPage] = useState(1)
  const [form, setForm] = useState({
    first_name: '',
    last_name: '',
    email: '',
    student_id: '',
  })
  const [message, setMessage] = useState('')

  const fetchStudents = async () => {
    try {
      const res = await fetch(`${API_URL}/api/v1/students/?page=${page}&per_page=10`)
      const data = await res.json()
      setStudents(data.items)
      setTotal(data.total)
    } catch (err) {
      console.error('Erreur chargement étudiants:', err)
    }
  }

  useEffect(() => {
    fetchStudents()
  }, [page])

  const handleSubmit = async (e) => {
    e.preventDefault()
    setMessage('')
    try {
      const res = await fetch(`${API_URL}/api/v1/students/`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(form),
      })
      if (res.status === 201) {
        setMessage('Étudiant inscrit avec succès !')
        setForm({ first_name: '', last_name: '', email: '', student_id: '' })
        fetchStudents()
      } else {
        const err = await res.json()
        setMessage(`Erreur : ${err.detail}`)
      }
    } catch (err) {
      setMessage('Erreur de connexion au serveur')
    }
  }

  return (
    <div>
      <h2>Inscription d'un étudiant</h2>
      <form onSubmit={handleSubmit} className="form">
        <input
          type="text"
          placeholder="Prénom"
          value={form.first_name}
          onChange={(e) => setForm({ ...form, first_name: e.target.value })}
          required
        />
        <input
          type="text"
          placeholder="Nom"
          value={form.last_name}
          onChange={(e) => setForm({ ...form, last_name: e.target.value })}
          required
        />
        <input
          type="email"
          placeholder="Email"
          value={form.email}
          onChange={(e) => setForm({ ...form, email: e.target.value })}
          required
        />
        <input
          type="text"
          placeholder="Matricule (ex: ETU-2024-005)"
          value={form.student_id}
          onChange={(e) => setForm({ ...form, student_id: e.target.value })}
          required
        />
        <button type="submit">Inscrire</button>
      </form>
      {message && <p className="message">{message}</p>}

      <h2>Liste des étudiants ({total})</h2>
      <table>
        <thead>
          <tr>
            <th>Matricule</th>
            <th>Prénom</th>
            <th>Nom</th>
            <th>Email</th>
          </tr>
        </thead>
        <tbody>
          {students.map((s) => (
            <tr key={s.id}>
              <td>{s.student_id}</td>
              <td>{s.first_name}</td>
              <td>{s.last_name}</td>
              <td>{s.email}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="pagination">
        <button onClick={() => setPage(page - 1)} disabled={page <= 1}>
          Précédent
        </button>
        <span>Page {page}</span>
        <button onClick={() => setPage(page + 1)} disabled={page * 10 >= total}>
          Suivant
        </button>
      </div>
    </div>
  )
}

export default Students