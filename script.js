import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  // Simulate 10 virtual users
  vus: 250,
  // Run the test for a duration of 30 seconds
  duration: '30s',
};

export default function () {
  // Make a GET request to the target URL
  http.get('http://127.0.0.1:8080/api/common/attendance');
  // Add a small delay between requests to be more realistic
  sleep(1);
}
