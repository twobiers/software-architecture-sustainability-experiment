import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  scenarios: {
    contacts: {
      gracefulRampDown: '0s',
    },
  },
};

export default function () {
  http.get(`http://${__ENV.SERVICE_HOST || 'localhost:8080'}/documents/3017620420009`);
}