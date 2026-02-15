CREATE TABLE IF NOT EXISTS students (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    student_id VARCHAR(20) UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS grades (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(id),
    subject VARCHAR(100) NOT NULL,
    score FLOAT NOT NULL,
    semester VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO students (first_name, last_name, email, student_id) VALUES
    ('Aminata', 'Ouédraogo', 'aminata.ouedraogo@ujkz.bf', 'ETU-2024-001'),
    ('Ibrahim', 'Sawadogo', 'ibrahim.sawadogo@ujkz.bf', 'ETU-2024-002'),
    ('Fatimata', 'Compaoré', 'fatimata.compaore@ujkz.bf', 'ETU-2024-003')
ON CONFLICT DO NOTHING;

INSERT INTO grades (student_id, subject, score, semester) VALUES
    (1, 'Génie Logiciel', 15.5, '2024-S1'),
    (1, 'Bases de Données', 14.0, '2024-S1'),
    (2, 'Génie Logiciel', 12.0, '2024-S1'),
    (2, 'Réseaux', 16.5, '2024-S1'),
    (3, 'Bases de Données', 17.0, '2024-S1'),
    (3, 'Systèmes', 13.5, '2024-S1')
ON CONFLICT DO NOTHING;