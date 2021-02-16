ARG tag=20.11
FROM nvcr.io/nvidia/tensorrt:${tag}-py3

ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt && rm requirements.txt

ADD app.py app.py
ENV FLASK_APP=app.py LC_ALL=C.UTF-8 LANG=C.UTF-8
ENTRYPOINT flask run --host=0.0.0.0