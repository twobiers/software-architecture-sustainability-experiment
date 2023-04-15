import http from 'k6/http';
import { sleep } from 'k6';
import { SharedArray } from 'k6/data';

const data = new SharedArray('products', function () {
  const productsFile = __ENV.PRODUCTS_FILE || './product_ids_1k.json';
  const ids = JSON.parse(open(productsFile));
  return ids;
});

export default function () {
  const id = data[Math.floor(Math.random() * data.length)];
  http.get(`http://localhost:8080/documents/${id}`);
  sleep(1);
}