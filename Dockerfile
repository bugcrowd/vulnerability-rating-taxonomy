FROM python:3.6

RUN pip install jsonschema GitPython semantic_version

WORKDIR /tmp/vrt
CMD [ "python3", "-B" , "./lib/validate_vrt.py" ]
