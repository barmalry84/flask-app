FROM python:3.12-slim

WORKDIR /api

COPY app.py ./

RUN pip install Flask

EXPOSE 5010

ENV FLASK_APP=app.py

CMD ["flask", "run", "--host=0.0.0.0", "--port=5010"] 
