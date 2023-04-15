import http from 'k6/http';
import { sleep } from 'k6';
import exec from 'k6/execution';
import { SharedArray } from 'k6/data';

const data = new SharedArray('products', function () {
  const productsFile = __ENV.PRODUCTS_FILE || './product_ids_1k.json';
  const ids = JSON.parse(open(productsFile));
  return ids;
});

export default function () {
  const id = data[(exec.scenario.iterationInInstance % data.length) - 1];
  http.get(`http://${__ENV.SERVICE_HOST || 'localhost:8080'}/documents/${id}`);
}