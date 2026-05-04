// Simple local server that runs bat files when called
const http = require('http');
const { exec } = require('child_process');

const PORT = 3000;

const server = http.createServer((req, res) => {
  
  // Only respond to our specific route
  if (req.url === '/run-archive' && req.method === 'GET') {
    
    console.log('Received request - running mega_archive.bat...');
    
    // Run the bat file
    exec('cmd /c "C:\\Users\\ravia\\Documents\\mega_archive.bat"', 
      (error, stdout, stderr) => {
        
        if (error) {
          console.error('Error:', error.message);
          res.writeHead(500);
          res.end(JSON.stringify({ 
            success: false, 
            error: error.message 
          }));
          return;
        }
        
        console.log('Success:', stdout);
        res.writeHead(200);
        res.end(JSON.stringify({ 
          success: true, 
          message: 'Archive completed',
          output: stdout
        }));
      }
    );

  } else {
    // Unknown route
    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

server.listen(PORT, () => {
  console.log(`n8n runner listening on http://localhost:${PORT}`);
  console.log(`Archive endpoint: http://localhost:${PORT}/run-archive`);
});