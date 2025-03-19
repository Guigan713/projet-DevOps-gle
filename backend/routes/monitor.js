const express = require('express');
const router = express.Router()
const client = require('prom-client');

const register = new client.Registry();

// Ajout d'un compteur de requêtes
const httpRequestCounter = new client.Counter({
    name: 'http_requests_total',
    help: 'Nombre total de requêtes HTTP',
    labelNames: ['method', 'route', 'status'],
});

// Ajout d'un histogramme pour mesurer la durée des requêtes
const httpRequestDuration = new client.Histogram({
    name: 'http_request_duration_seconds',
    help: 'Durée des requêtes HTTP',
    labelNames: ['method', 'route', 'status'],
    buckets: [0.1, 0.3, 0.5, 1, 2, 5], // Temps en secondes
});

// Ajout des métriques au registre Prometheus
register.registerMetric(httpRequestCounter);
register.registerMetric(httpRequestDuration);


// Middleware pour enregistrer les métriques
app.use((req, res, next) => {
    const start = Date.now();
    res.on('finish', () => {
      const duration = (Date.now() - start) / 1000;
      httpRequestCounter.inc({ method: req.method, route: req.path, status: res.statusCode });
      httpRequestDuration.observe({ method: req.method, route: req.path, status: res.statusCode }, duration);
    });
    next();
});
  
  // Endpoint pour récupérer les métriques
app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.send(await register.metrics());
});

module.exports = router
