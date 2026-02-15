import { useState } from 'react'
import Students from './components/Students'
import Grades from './components/Grades'
import Compute from './components/Compute'

const tabs = [
  { id: 'students', label: 'Étudiants' },
  { id: 'grades', label: 'Notes' },
  { id: 'compute', label: 'Calcul intensif' },
]

function App() {
  const [activeTab, setActiveTab] = useState('students')

  return (
    <div className="container">
      <h1>Application Académique</h1>
      <nav className="tabs">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            className={activeTab === tab.id ? 'tab active' : 'tab'}
            onClick={() => setActiveTab(tab.id)}
          >
            {tab.label}
          </button>
        ))}
      </nav>
      <main>
        {activeTab === 'students' && <Students />}
        {activeTab === 'grades' && <Grades />}
        {activeTab === 'compute' && <Compute />}
      </main>
    </div>
  )
}

export default App