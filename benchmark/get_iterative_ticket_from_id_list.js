import http from 'k6/http';
import { sleep } from 'k6';
import exec from 'k6/execution';
import { SharedArray } from 'k6/data';

const data = new SharedArray('tickets', function () {
  const ids = JSON.parse(open('./ticket_ids.json'));
  return ids;
});

export default function () {
  const id = data[(exec.scenario.iterationInInstance % data.length) - 1];
  http.get(`http://localhost:8080/tickets/${id}`);
  sleep(1);
}