build: clean
	python3 -m pip install --upgrade --quiet setuptools wheel twine
	python3 setup.py sdist bdist_wheel

publish: build
	python3 -m twine check dist/*
	python3 -m twine upload dist/*

test: build
	python3 -m twine check dist/*
	python3 -m twine upload --repository testpypi dist/*

clean:
	rm -r build dist *.egg-info || true