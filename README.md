# jenkins

Custom jenkins images with docker-compose,docker and all the plugins pre-installed

If you are using this on production, you may want to comment the passowrd setup on the jenkins file

```sh
docker build -t myjenkins .
docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 8080:8080 myjenkins
```

