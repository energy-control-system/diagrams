docker run -d --rm -p 8080:8080 -v "$(pwd)/Structurizr":/usr/local/structurizr structurizr/lite
docker run -d --rm -p 8081:8080 plantuml/plantuml-server:jetty
