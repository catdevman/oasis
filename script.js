import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  // Simulate 200 virtual users to see decent load (reduced from 2500 so we don't overwhelm immediately on multiple endpoints)
  vus: 200,
  // Run the test for a duration of 30 seconds
  duration: '30s',
};

const endpoints = [
  'student-academic-records',
  'assessments',
  'attendances',
  'bell-schedules',
  'calendars',
  'cohorts',
  'course-catalogs',
  'credentials',
  'disciplines',
  'education-organizations',
  'grades',
  'graduation-plans',
  'interventions',
  'post-secondary-events',
  'programs',
  'sections',
  'staffs',
  'students',
  'student-section-associations'
];

export default function () {
  // Randomly select one of the endpoints
  const endpoint = endpoints[Math.floor(Math.random() * endpoints.length)];
  
  // Make a GET request to the selected endpoint
  http.get(`http://127.0.0.1:8080/api/common/ed-fi/${endpoint}`);
  
  // Add a small delay between requests to be more realistic
  sleep(1);
}
