import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';

export const options = {
  scenarios: {
    inscription_peak: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '30s', target: 200 },
        { duration: '1m', target: 200 },
        { duration: '30s', target: 0 },
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    http_req_failed: ['rate<0.05'],
  },
};

let counter = 0;

export default function () {
  const id = `${__VU}-${__ITER}-${counter++}`;

  // 70% lectures, 30% écritures (inscriptions)
  if (Math.random() < 0.3) {
    const payload = JSON.stringify({
      first_name: `Prenom${id}`,
      last_name: `Nom${id}`,
      email: `etudiant${id}@ujkz.bf`,
      student_id: `ETU-K6-${id}`,
    });

    const res = http.post(`${BASE_URL}/api/v1/students/`, payload, {
      headers: { 'Content-Type': 'application/json' },
    });

    check(res, {
      'created 201': (r) => r.status === 201,
    });
  } else {
    const res = http.get(`${BASE_URL}/api/v1/students/?page=1&per_page=10`);

    check(res, {
      'status is 200': (r) => r.status === 200,
    });
  }

  sleep(0.5);
}