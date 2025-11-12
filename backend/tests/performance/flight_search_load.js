import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 100 }, // Ramp up to 100 users
    { duration: '1m', target: 100 },  // Stay at 100 users
    { duration: '30s', target: 0 },   // Ramp down to 0 users
  ],
};

export default function () {
  // Test flight search endpoint
  let searchPayload = JSON.stringify({
    max_price: 800.0,
    max_stops: 1,
  });
  
  let params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };
  
  let res = http.post('http://localhost:8000/flights/search', searchPayload, params);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
    'has flights in response': (r) => r.json().flights.length > 0,
  });
  
  sleep(1);
}