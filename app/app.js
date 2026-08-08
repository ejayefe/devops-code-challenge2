const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'Hello World from EKS!',
    timestamp: new Date().toISOString(),
    podName: process.env.HOSTNAME || 'local-environment'
  });
});

// Liveness and Readiness probes for Kubernetes
app.get('/healthz', (req, res) => {
  res.status(200).send('OK');
});

app.listen(PORT, () => {
  console.log(`Application started on port ${PORT}`);
});