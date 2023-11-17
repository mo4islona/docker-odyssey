## Docker 

### Build
```bash
docker buildx build -t odyssey .
```

### Run 
```bash
PORT=6432 && \
docker run -p $PORT:$PORT -t --name odyssey --env PORT=$PORT odyssey && \
docker rm -f odyssey
```