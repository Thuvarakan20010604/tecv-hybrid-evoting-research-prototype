.PHONY: setup start stop reset seed test benchmark attack-test research-run generate-report
setup:
	npm install
start:
	docker compose up -d couchdb
stop:
	docker compose down
reset:
	docker compose down -v
seed:
	npm run seed
test:
	npm test
benchmark:
	npm run benchmark
attack-test:
	npm run attack-test
research-run:
	npm run research-run
generate-report:
	npm run report
