import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';

export const options = {
  scenarios: {
    results_peak: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 300 },
        { duration: '6m', target: 300 },
        { duration: '2m', target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    http_req_failed: ['rate<0.05'],
  },
};

export default function () {
  const studentId = Math.floor(Math.random() * 3) + 1;
  const subjects = ['Génie Logiciel', 'Bases de Données', 'Réseaux', 'Systèmes'];
  const subject = subjects[Math.floor(Math.random() * subjects.length)];

  const endpoints = [
    `${BASE_URL}/api/v1/grades/`,
    `${BASE_URL}/api/v1/grades/?student_id=${studentId}`,
    `${BASE_URL}/api/v1/grades/?subject=${encodeURIComponent(subject)}`,
    `${BASE_URL}/api/v1/students/?page=1&per_page=10`,
  ];

  const url = endpoints[Math.floor(Math.random() * endpoints.length)];
  const res = http.get(url);

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(0.3);
}